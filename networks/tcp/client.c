// TCP Client for Tic-Tac-Toe in C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define MAX 1024

void print_board(char board[3][3])
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
void handlegame(int sock, int valread, char buffer[MAX], char board[3][3])
{
}

int main()
{
    int sock = 0, valread;
    struct sockaddr_in serv_addr;
    char buffer[MAX] = {0};
    char board[3][3];

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("\n Socket creation error \n");
        return -1;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    // Convert IPv4 and IPv6 addresses from text to binary form
    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0)
    {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        printf("\nConnection Failed \n");
        return -1;
    }
    else
    {
        recv(sock, buffer, MAX, 0);
        printf("%s\n", buffer);
    }
    int flag = 1;
    // handlegame(sock, valread, buffer, board);
    while (flag)
    {
        while (1)
        {
            valread = recv(sock, buffer, MAX, 0);
            if (valread <= 0)
            {
                printf("Server disconnected.\n");
                break;
            }
            if (strcmp(buffer, "board") == 0)
            {
                // Receive the updated board state
                valread = recv(sock, board, sizeof(board), 0);
                if (valread <= 0)
                {
                    printf("Server disconnected.\n");
                    break;
                }

                // Print the current board state
                print_board(board);
            }
            else
            {
                // Receive and print the server's message (e.g., "Your move")
                valread = recv(sock, buffer, MAX, 0);
                if (valread <= 0)
                {
                    printf("Server disconnected.\n");
                    break;
                }

                printf("%s", buffer);
                if (strstr(buffer, "Invalid") != NULL)
                {
                    continue;
                }
                // Check if the game is over
                if (strstr(buffer, "wins") != NULL || strstr(buffer, "draw") != NULL)
                {
                    valread = recv(sock, board, sizeof(board), 0);
                    if (valread <= 0)
                    {
                        printf("Server disconnected.\n");
                        break;
                    }

                    // Print the current board state
                    print_board(board);
                    break; // Exit the loop when the game ends
                }

                // Take input from the user for their move
                int row, col;
                scanf("%d %d", &row, &col);
                sprintf(buffer, "%d %d", row, col);

                // Send the move to the server
                send(sock, buffer, strlen(buffer), 0);
            }
        }

        // Ask if the player wants a rematch
        valread = recv(sock, buffer, MAX, 0);
        if (valread > 0)
        {
            printf("%s", buffer);
            int rematch;
            scanf("%d", &rematch);
            sprintf(buffer, "%d", rematch);
            send(sock, buffer, strlen(buffer), 0);
            valread = recv(sock, buffer, MAX, 0);
            printf("%s\n", buffer);
            if (strcmp(buffer, "New match begins ..") != 0)
            {
                flag = 0;
            }
        }
    }

    close(sock);
    return 0;
}
