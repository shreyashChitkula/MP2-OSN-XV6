#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>

#define PORT 8080
#define MAX 1024

char board[3][3];    // Tic-Tac-Toe board
int player_turn = 1; // Start with player 1
int moves = 0;       // Number of moves made
char symbols[]={'X','O'};

int sockfd;
struct sockaddr_in server_addr, client_addr1, client_addr2;
char buffer[MAX];
socklen_t addr_len = sizeof(struct sockaddr_in);

// Initialize the board with empty spaces
void initialize_board()
{
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            board[i][j] = ' ';
}

// Print the board (for server-side logging)
void print_board()
{
    printf("\n");
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

    // Check if the board is full (draw)
    if (moves >= 9)
        return 0;

    return -1; // Game is still ongoing
}

// Update the board based on the player's move
int update_board(int player, int row, int col)
{
    if (row < 1 || row > 3 || col < 1 || col > 3 || board[row][col] != ' ')
        return -1; // Invalid move

    board[row-1][col-1] = (player == 1) ? 'X' : 'O';
    moves++;
    print_board();
    return 0;
}
void indicate_message_to_player(struct sockaddr_in *current_player)
{
    char buffer[MAX];
    sprintf(buffer, "message");
    sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)current_player, addr_len);
}
void indicate_message()
{
    indicate_message_to_player(&client_addr1);
    indicate_message_to_player(&client_addr2);
}
void send_board_to_players(int flag)
{
    char buffer[MAX];
    sprintf(buffer, "board");
    for (int i = 0; i < 2; i++)
    {
        if (flag)
        {
            i == 0 ? sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr1, addr_len) : sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr2, addr_len);
        }
        sendto(sockfd, board, sizeof(board), 0, i == 0 ? (const struct sockaddr *)&client_addr1 : (const struct sockaddr *)&client_addr2, addr_len);
    }
}
void handle_game()
{
    int row, col, winner;
    while (1)
    {
        // Send board to both players
        send_board_to_players(1);

        // Get current player address
        struct sockaddr_in *current_player = (player_turn == 1) ? &client_addr1 : &client_addr2;

        indicate_message_to_player(current_player);
        sprintf(buffer, "Your move, Player %d (Symbol: %c): ", player_turn, symbols[player_turn-1]);
        sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)current_player, addr_len);

        // Receive the move
        recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)current_player, &addr_len);
        sscanf(buffer, "%d %d", &row, &col);

        // Validate the move
        if (update_board(player_turn, row, col) == 0)
        {
            player_turn = (player_turn == 1) ? 2 : 1; // Switch turn
        }
        else
        {
            indicate_message_to_player(current_player);
            sendto(sockfd, "Invalid move, try again\n", strlen("Invalid move, try again\n"), 0, (const struct sockaddr *)current_player, addr_len);
            continue;
        }

        // Check for winner or draw
        winner = check_winner();
        if (winner != -1)
        {
            // print_board();
            indicate_message();
            if (winner == 1)
            {
                sendto(sockfd, "Player 1 Wins!", strlen("Player 1 Wins!"), 0, (const struct sockaddr *)&client_addr1, addr_len);
                sendto(sockfd, "Player 1 Wins!", strlen("Player 1 Wins!"), 0, (const struct sockaddr *)&client_addr2, addr_len);
            }
            else if (winner == 2)
            {
                sendto(sockfd, "Player 2 Wins!", strlen("Player 2 Wins!"), 0, (const struct sockaddr *)&client_addr1, addr_len);
                sendto(sockfd, "Player 2 Wins!", strlen("Player 2 Wins!"), 0, (const struct sockaddr *)&client_addr2, addr_len);
            }
            else
            {
                sendto(sockfd, "It's a Draw!", strlen("It's a Draw!"), 0, (const struct sockaddr *)&client_addr1, addr_len);
                sendto(sockfd, "It's a Draw!", strlen("It's a Draw!"), 0, (const struct sockaddr *)&client_addr2, addr_len);
            }
            send_board_to_players(0);
            break;
        }
    }
}
int prompt_rematch()
{
    char buffer[MAX];
    int rematch_response[2];

    sprintf(buffer, "Do you want a rematch? (1 for Yes, 0 for No): ");
    sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&client_addr1, addr_len);
    recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addr1, &addr_len);
    rematch_response[0] = atoi(buffer);

    sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&client_addr2, addr_len);
    recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addr2, &addr_len);
    rematch_response[1] = atoi(buffer);

    // If both players want a rematch, return 1, otherwise return 0
    if (rematch_response[0] == 1 && rematch_response[1] == 1)
    {
        // indicate_message();
        sprintf(buffer, "New match begins ..\n");
        sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&client_addr1, addr_len);
        sendto(sockfd, buffer, strlen(buffer), 0, (const struct sockaddr *)&client_addr2, addr_len);
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
                i == 0 ? sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr1, addr_len) : sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr2, addr_len);
            }
            else
            {
                sprintf(buffer, "Game Over!..\n\n");
                i == 0 ? sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr1, addr_len) : sendto(sockfd, buffer, sizeof(buffer), 0, (const struct sockaddr *)&client_addr2, addr_len);
            }
        }

        return 0;
    }
}

int main()
{
    // Create socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Initialize server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    // Bind the socket
    if (bind(sockfd, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        perror("Bind failed");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    printf("Waiting for players to connect...\n");

    // Receive connection from Player 1
    recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addr1, &addr_len);
    printf("Player 1 connected\n");
    sendto(sockfd, "You are Player 1 (X)", strlen("You are Player 1 (X)"), 0, (const struct sockaddr *)&client_addr1, addr_len);

    // Receive connection from Player 2
    recvfrom(sockfd, buffer, sizeof(buffer), 0, (struct sockaddr *)&client_addr2, &addr_len);
    printf("Player 2 connected\n");
    sendto(sockfd, "You are Player 2 (O)", strlen("You are Player 2 (O)"), 0, (const struct sockaddr *)&client_addr2, addr_len);

    int play_again = 1;
    // Start the game
    while (play_again)
    {
        initialize_board();
        print_board();
        handle_game();
        play_again = prompt_rematch();
    }
    close(sockfd);
    return 0;
}
