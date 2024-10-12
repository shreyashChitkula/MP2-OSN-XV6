// TCP Server for Tic-Tac-Toe in C with rematch functionality
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define PORT 8080
#define MAX 1024

char board[3][3]; // Tic-Tac-Toe board
int players[2];   // Sockets for the two players
char symbols[] = {'X', 'O'};
int current_player = 0; // 0 for Player 1, 1 for Player 2

void initialize_board()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            board[i][j] = ' ';
        }
    }
}

void print_board()
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
}

// int check_winner()
// {
//     // Check rows and columns
//     for (int i = 0; i < 3; i++)
//     {
//         if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != ' ')
//             return 1;
//         if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != ' ')
//             return 1;
//     }
//     // Check diagonals
//     if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' ')
//         return 1;
//     if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' ')
//         return 1;

//     return 0;
// }

int is_board_full()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (board[i][j] == ' ')
            {
                return 0;
            }
        }
    }
    return 1;
}

void send_board_to_players(int flag)
{
    char buffer[MAX];
    sprintf(buffer, "board");
    for (int i = 0; i < 2; i++)
    {
        if (flag)
        {
            send(players[i], buffer, sizeof(buffer), 0);
        }
        send(players[i], board, sizeof(board), 0);
    }
}
void indicate_message_to_player(int socket)
{
    char buffer[MAX];
    sprintf(buffer, "message");
    send(socket, buffer, sizeof(buffer), 0);
}
void indicate_message()
{
    for (int i = 0; i < 2; i++)
    {
        indicate_message_to_player(players[i]);
    }
}
void switch_player()
{
    current_player = (current_player + 1) % 2;
}

int prompt_rematch()
{
    char buffer[MAX];
    int rematch_response[2];

    // Ask both players if they want to play again
    // indicate_message();
    for (int i = 0; i < 2; i++)
    {
        sprintf(buffer, "Do you want a rematch? (1 for Yes, 0 for No): ");
        send(players[i], buffer, sizeof(buffer), 0);
        recv(players[i], buffer, sizeof(buffer), 0);
        rematch_response[i] = atoi(buffer);
    }

    // If both players want a rematch, return 1, otherwise return 0
    if (rematch_response[0] == 1 && rematch_response[1] == 1)
    {
        // indicate_message();
        sprintf(buffer, "New match begins ..\n");
        send(players[0], buffer, sizeof(buffer), 0);
        send(players[1], buffer, sizeof(buffer), 0);
        return 1;
    }
    else
    {
        for (int i = 0; i < 2; i++)
        {
            // indicate_message();
            if (rematch_response[i] == 1)
            {
                sprintf(buffer, "opponent did not wish to play\n\n");
                send(players[i], buffer, sizeof(buffer), 0);
            }
            else
            {
                sprintf(buffer, "Game Over!..\n\n");
                send(players[i], buffer, sizeof(buffer), 0);
            }
        }

        return 0;
    }
}

// Update the board based on the player's move
int update_board(int player, int row, int col)
{
    if (row < 1 || row > 3 || col < 1 || col > 3 || board[row][col] != ' ')
        return -1; // Invalid move

    board[row-1][col-1] = symbols[current_player];
    print_board();
    return 0;
}

// Check for a winner or a draw
int check_winner()
{
    // Check rows, columns, and diagonals
    for (int i = 0; i < 3; i++)
    {
        if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != ' ')
            return board[i][0] == 'X' ? 1 : 2;
        if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != ' ')
            return board[0][i] == 'X' ? 1 : 2;
    }
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != ' ')
        return board[0][0] == 'X' ? 1 : 2;
    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != ' ')
        return board[0][2] == 'X' ? 1 : 2;

    int flag = 1;
    // Check if the board is full (draw)
    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            if (board[i][j] == ' ')
            {
                flag = 0;
            }
        }
    }
    if (flag)
    {
        return 0;
    }

    return -1; // Game is still ongoing
}

void handle_game()
{
    char buffer[MAX];
    int row, col;
    while (1)
    {
        // Send the current board state to both players
        send_board_to_players(1);

        // Send notification to current player
        indicate_message_to_player(players[current_player]);
        sprintf(buffer, "Your move, Player %d (Symbol: %c): ", current_player + 1, symbols[current_player]);
        send(players[current_player], buffer, sizeof(buffer), 0);
        // indicate_message_to_player(players[!current_player]);
        // sprintf(buffer, "Player %d turn (Symbol: %c)", current_player + 1, symbols[current_player]);
        // send(players[!current_player], buffer, sizeof(buffer), 0);

        // Receive move from current player
        recv(players[current_player], buffer, MAX, 0);
        sscanf(buffer, "%d %d", &row, &col);

        // Validate the move
        if (update_board(current_player, row, col) == 0)
        {
            switch_player(); // Switch turn
        }
        else
        {
            indicate_message_to_player(players[current_player]);
            sprintf(buffer, "Invalid move, try again.\n");
            send(players[current_player], buffer, sizeof(buffer), 0);
            // continue;
        }

        // Check for winner or draw
        int winner = check_winner();
        if (winner != -1)
        {
            // print_board();
            indicate_message();
            if (winner == 1 || winner == 2)
            {
                sprintf(buffer, "Player %d wins!\n", winner);
                for (int i = 0; i < 2; i++)
                {
                    send(players[i], buffer, sizeof(buffer), 0);
                }
            }
            else
            {
                sprintf(buffer, "It's a draw!\n");
                for (int i = 0; i < 2; i++)
                {
                    send(players[i], buffer, sizeof(buffer), 0);
                }
            }
            send_board_to_players(0);
            break;
        }

        // Check for valid move
        // if (board[row][col] == ' ')
        // {
        //     board[row][col] = symbols[current_player];
        //     print_board();

        //     // Check for winner or draw
        //     if (check_winner())
        //     {
        //         indicate_message();
        //         sprintf(buffer, "Player %d wins!\n", current_player + 1);
        //         send(players[0], buffer, sizeof(buffer), 0);
        //         send(players[1], buffer, sizeof(buffer), 0);
        //         send_board_to_players(0);
        //         break;
        //     }
        //     else if (is_board_full())
        //     {
        //         indicate_message();
        //         sprintf(buffer, "It's a draw!\n");
        //         send(players[0], buffer, sizeof(buffer), 0);
        //         send(players[1], buffer, sizeof(buffer), 0);
        //         send_board_to_players(0);
        //         break;
        //     }

        //     // Switch player
        //     switch_player();
        // }
        // else
        // {
        //     indicate_message_to_player(players[current_player]);
        //     sprintf(buffer, "Invalid move, try again.\n");
        //     send(players[current_player], buffer, sizeof(buffer), 0);
        // }
    }
}

int main()
{
    char buffer[MAX];
    int server_fd, new_socket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0)
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    // Bind
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    // Listen for connections
    if (listen(server_fd, 2) < 0)
    {
        perror("listen failed");
        exit(EXIT_FAILURE);
    }
    printf("Waiting for players...\n");

    // Accept two players
    for (int i = 0; i < 2; i++)
    {
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t *)&addrlen)) < 0)
        {
            perror("accept failed");
            exit(EXIT_FAILURE);
        }
        players[i] = new_socket;
        printf("Player %d connected.\n", i + 1);
        snprintf(buffer, sizeof(buffer), "Welcome Player %d! You are %c.", i + 1, symbols[i]);
        send(new_socket, buffer, strlen(buffer), 0);
    }

    // Start the game loop
    int play_again = 1;
    while (play_again)
    {
        // Initialize the board and print the current state
        initialize_board();
        print_board();

        // Handle the game
        handle_game();

        // Check if players want a rematch
        play_again = prompt_rematch();
    }

    printf("Game Over! Closing connections.\n");

    // Close the connections after the game ends
    for (int i = 0; i < 2; i++)
    {
        close(players[i]);
    }

    close(server_fd);
    return 0;
}
