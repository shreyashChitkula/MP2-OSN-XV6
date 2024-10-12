#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>

#define PORT 8080
#define BUFFER_SIZE 1024 // Define a buffer size

// Function to display the game board
void display_board(char board[3][3])
{
    printf("\nCurrent Board:\n");
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            printf(" %c ", board[i][j]);
            if (j < 2)
                printf("|");
        }
        printf("\n");
        if (i < 2)
            printf("---|---|---\n");
    }
    printf("\n");
}

int main()
{
    int sockfd;
    struct sockaddr_in server_addr;
    char buffer[BUFFER_SIZE];
    socklen_t addr_len = sizeof(server_addr);
    char board[3][3];
    int bytes_received;

    // Create socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Server address initialization
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = INADDR_ANY;

    // Connect to the server
    sendto(sockfd, "Connect", strlen("Connect"), 0, (const struct sockaddr *)&server_addr, addr_len);

    // Receive player role
    bytes_received = recvfrom(sockfd, buffer, BUFFER_SIZE, 0, (struct sockaddr *)&server_addr, &addr_len);
    buffer[bytes_received] = '\0'; // Add a null terminator
    printf("%s\n", buffer);

    int flag = 1;
    while (flag)
    {
        // Start the game
        while (1)
        {
            // Receive the current game board
            bytes_received = recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&server_addr, &addr_len);
            buffer[bytes_received] = '\0'; // Add a null terminator if needed (ensure it's string-friendly)
            // printf("%s\n", buffer);
            if (strcmp(buffer, "board") == 0)
            {
                bytes_received = recvfrom(sockfd, board, sizeof(board), 0, (struct sockaddr *)&server_addr, &addr_len);
                display_board(board);
            }
            else
            {
                bytes_received = recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&server_addr, &addr_len);
                buffer[bytes_received] = '\0';
                printf("%s", buffer);
                if (strstr(buffer, "Invalid") != NULL)
                {
                    continue;
                }
                // Check if the game is over
                if (strstr(buffer, "Wins") != NULL || strstr(buffer, "Draw") != NULL)
                {
                    bytes_received = recvfrom(sockfd, board, sizeof(board), 0, (struct sockaddr *)&server_addr, &addr_len);
                    display_board(board);
                    break; // Exit the loop when the game ends
                }

                // Take input from the user for their move
                int row, col;
                scanf("%d %d", &row, &col);
                sprintf(buffer, "%d %d", row, col);

                // Send the move to the server
                sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&server_addr, addr_len);
            }
        }
        // Ask if the player wants a rematch
        bytes_received = recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&server_addr, &addr_len);
        if (bytes_received > 0)
        {
            printf("%s", buffer);
            int rematch;
            scanf("%d", &rematch);
            sprintf(buffer, "%d", rematch);
            sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&server_addr, addr_len);
            recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&server_addr, &addr_len);
            printf("%s\n", buffer);
            if (strcmp(buffer, "New match begins ..") != 0)
            {
                flag = 0;
            }
        }
    }

    close(sockfd);
    return 0;
}
