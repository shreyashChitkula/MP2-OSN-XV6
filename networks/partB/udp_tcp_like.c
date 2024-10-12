#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>
#include <errno.h>

#define MAX_BUFFER 1024
#define CHUNK_SIZE 100
#define ACK_TIMEOUT 100000 // 0.1 seconds in microseconds

typedef struct
{
    int seq_num;
    int total_chunks;
    int data_size;
    char data[CHUNK_SIZE];
} Chunk;

typedef struct
{
    int seq_num;
} Ack;

int create_socket()
{
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }
    return sockfd;
}

void set_nonblocking(int sockfd)
{
    int flags = fcntl(sockfd, F_GETFL, 0);
    if (flags == -1)
    {
        perror("Error getting socket flags");
        exit(EXIT_FAILURE);
    }
    if (fcntl(sockfd, F_SETFL, flags | O_NONBLOCK) == -1)
    {
        perror("Error setting socket to non-blocking");
        exit(EXIT_FAILURE);
    }
}

void send_data(int sockfd, const struct sockaddr *addr, socklen_t addr_len, const char *data)
{
    int data_len = strlen(data);
    int total_chunks = (data_len + CHUNK_SIZE - 1) / CHUNK_SIZE;
    int sent_chunks[total_chunks];
    memset(sent_chunks, 0, sizeof(sent_chunks));

    for (int i = 0; i < total_chunks; i++)
    {
        Chunk chunk;
        chunk.seq_num = i;
        chunk.total_chunks = total_chunks;
        int chunk_len = (i == total_chunks - 1) ? (data_len % CHUNK_SIZE) : CHUNK_SIZE;
        chunk.data_size = chunk_len;
        memcpy(chunk.data, data + i * CHUNK_SIZE, chunk_len);

        int retries = 0;
        while (!sent_chunks[i] && retries < 5)
        {
            sendto(sockfd, &chunk, sizeof(Chunk), 0, addr, addr_len);
            printf("Sent chunk %d/%d (size: %d)\n", i + 1, total_chunks, chunk_len);

            fd_set readfds;
            FD_ZERO(&readfds);
            FD_SET(sockfd, &readfds);

            struct timeval tv;
            tv.tv_sec = 0;
            tv.tv_usec = ACK_TIMEOUT;

            if (select(sockfd + 1, &readfds, NULL, NULL, &tv) > 0)
            {
                Ack ack;
                ssize_t recv_len = recvfrom(sockfd, &ack, sizeof(Ack), 0, NULL, NULL);
                if (recv_len > 0 && ack.seq_num == i)
                {
                    sent_chunks[i] = 1;
                    printf("Received ACK for chunk %d\n", i + 1);
                    break;
                }
            }
            printf("Timeout, resending chunk %d (retry %d)\n", i + 1, retries + 1);
            retries++;
        }
        if (retries == 5)
        {
            printf("Failed to send chunk %d after 5 retries\n", i + 1);
        }
    }
}

void receive_data(int sockfd, struct sockaddr *addr, socklen_t *addr_len)
{
    Chunk chunks[MAX_BUFFER];
    int received_chunks = 0;
    int total_chunks = 0;
    int total_data_size = 0;
    struct timeval tv;
    tv.tv_sec = 30; // 30 seconds timeout
    tv.tv_usec = 0;

    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
    {
        perror("Error setting socket timeout");
        return;
    }

    printf("Waiting for data from client...\n");

    while (received_chunks < total_chunks || total_chunks == 0)
    {
        Chunk chunk;
        ssize_t recv_len = recvfrom(sockfd, &chunk, sizeof(Chunk), 0, addr, addr_len);

        if (recv_len > 0)
        {
            if (total_chunks == 0)
            {
                total_chunks = chunk.total_chunks;
                printf("Expecting %d chunks\n", total_chunks);
            }

            printf("Received chunk %d/%d (size: %d)\n", chunk.seq_num + 1, total_chunks, chunk.data_size);

            // Simulate random ACK loss (uncomment for testing)
            if (chunk.seq_num % 2 != 1) {
                Ack ack;
                ack.seq_num = chunk.seq_num;
                sendto(sockfd, &ack, sizeof(Ack), 0, addr, *addr_len);
                printf("Sent ACK for chunk %d\n", chunk.seq_num + 1);
            } else {
                printf("Simulating ACK loss for chunk %d\n", chunk.seq_num + 1);
            }

            // Ack ack;
            // ack.seq_num = chunk.seq_num;
            // sendto(sockfd, &ack, sizeof(Ack), 0, addr, *addr_len);
            // printf("Sent ACK for chunk %d\n", chunk.seq_num + 1);

            if (chunks[chunk.seq_num].seq_num != chunk.seq_num || strcmp(chunks[chunk.seq_num].data, chunk.data) != 0)
            {
                chunks[chunk.seq_num] = chunk;
                received_chunks++;
                total_data_size += chunk.data_size;
            }
        }
        else if (recv_len == 0)
        {
            printf("Connection closed by peer\n");
            break;
        }
        else
        {
            if (errno == EAGAIN || errno == EWOULDBLOCK)
            {
                printf("Timeout waiting for data. Received %d/%d chunks\n", received_chunks, total_chunks);
                break;
            }
            else
            {
                perror("recvfrom failed");
                break;
            }
        }
    }

    if (received_chunks == total_chunks)
    {
        printf("Received all chunks. Reconstructing data:\n");
        char *full_message = malloc(total_data_size + 1);
        if (full_message == NULL)
        {
            perror("Failed to allocate memory for message");
            return;
        }

        int current_pos = 0;
        for (int i = 0; i < total_chunks; i++)
        {
            memcpy(full_message + current_pos, chunks[i].data, chunks[i].data_size);
            current_pos += chunks[i].data_size;
        }
        full_message[total_data_size] = '\0';

        printf("Received message:\n%s\n", full_message);
        free(full_message);
    }
    else
    {
        printf("Failed to receive all chunks. Got %d/%d\n", received_chunks, total_chunks);
    }
}

int main(int argc, char *argv[])
{
    if (argc != 4)
    {
        fprintf(stderr, "Usage: %s <ip> <port> <s|c>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *ip = argv[1];
    int port = atoi(argv[2]);
    char mode = argv[3][0];

    int sockfd = create_socket();
    // set_nonblocking(sockfd);

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(ip);

    if (mode == 's')
    {
        if (bind(sockfd, (struct sockaddr *)&addr, sizeof(addr)) < 0)
        {
            perror("Bind failed");
            exit(EXIT_FAILURE);
        }
        printf("Server listening on %s:%d\n", ip, port);

        struct sockaddr_in client_addr;
        socklen_t client_addr_len = sizeof(client_addr);
        receive_data(sockfd, (struct sockaddr *)&client_addr, &client_addr_len);

        const char *response = "Hello from server! This is a response to acknowledge the receipt of your message.";
        send_data(sockfd, (struct sockaddr *)&client_addr, client_addr_len, response);
    }
    else if (mode == 'c')
    {
        const char *message = "Hello from client! This is a longer message to test multiple chunks. It should be split into several pieces and then reassembled correctly on the server side.";
        send_data(sockfd, (struct sockaddr *)&addr, sizeof(addr), message);

        receive_data(sockfd, (struct sockaddr *)&addr, &(socklen_t){sizeof(addr)});
    }
    else
    {
        fprintf(stderr, "Invalid mode. Use 's' for server or 'c' for client.\n");
        exit(EXIT_FAILURE);
    }

    close(sockfd);
    return 0;
}