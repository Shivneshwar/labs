/* 
 * Main source code file for lsh shell program
 *
 * You are free to add functions to this file.
 * If you want to add functions in a separate file 
 * you will need to modify Makefile to compile
 * your additional functions.
 *
 * Add appropriate comments in your code to make it
 * easier for us while grading your assignment.
 *
 * Submit the entire lab1 folder as a tar archive (.tgz).
 * Command to create submission archive: 
      $> tar cvf lab1.tgz lab1/
 *
 * All the best 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "parse.h"
#include<unistd.h>
#include<sys/types.h>
#include<sys/wait.h>
#include <signal.h>
#include <fcntl.h>

#define TRUE 1
#define FALSE 0

void RunCommand(int, Command *);
void DebugPrintCommand(int, Command *);
void PrintPgm(Pgm *);
void stripwhite(char *);

pid_t child_id = -1;

void signal_handler(int sig) {
  if(child_id>0) {
    kill(child_id, SIGKILL);
  }
}

int main(void)
{
  signal(SIGINT, signal_handler);
  signal(SIGCHLD, SIG_IGN);
  
  Command cmd;
  int parse_result;

  while (TRUE)
  {
    child_id = -1;
    char *line;
    line = readline("> ");

    /* If EOF encountered, exit shell */
    if (!line)
    {
      break;
    }
    /* Remove leading and trailing whitespace from the line */
    stripwhite(line);
    /* If stripped line not blank */
    if (*line)
    {
      add_history(line);
      parse_result = parse(line, &cmd);
      RunCommand(parse_result, &cmd);
    }

    /* Clear memory */
    free(line);
  }
  return 0;
}


// Function to execute builtin commands
int ownCmdHandler(char** parsed)
{
  int NoOfOwnCmds = 2, i, switchOwnArg = 0;
  char* ListOfOwnCmds[NoOfOwnCmds];

  ListOfOwnCmds[0] = "exit";
  ListOfOwnCmds[1] = "cd";

  for (i = 0; i < NoOfOwnCmds; i++) {
    if (strcmp(parsed[0], ListOfOwnCmds[i]) == 0) {
      switchOwnArg = i + 1;
      break;
    }
  }

  switch (switchOwnArg) {
    case 1:
      printf("\nGoodbye\n");
      exit(0);
    case 2:
      if(parsed[1]==NULL)
        parsed[1]=getenv("HOME");
      if(chdir(parsed[1])!=0)
        perror("cd failed due to");
      return 1;
    default:
      break;
  }

  return 0;
}
  

// Function where the system command is executed
void execArgs(char** parsed, int in, int out, int background)
{

  // Forking a child
  pid_t pid = fork(); 

  if (pid == -1) {
    perror("Failed forking child");
    return;
  } else if (pid == 0) {
    if(in != 0) {
      dup2(in, 0);
      close(in);
    }
    if(out != 1) {
      dup2(out, 1);
      close(out);
    }
    if(background==TRUE) {
      signal(SIGINT, SIG_IGN);
    }
    if (execvp(parsed[0], parsed) < 0) {
      perror("Could not execute command");
    } 
    exit(0);
  } else {
    // waiting for child to terminate
    if(background==FALSE) {
      child_id = pid;
      waitpid(pid, NULL, 0);
    }
    return;
  }
}

/*
* Creates a new node using the malloc function
*/
Pgm* create_node(char** data)
{
  Pgm* new_node = (Pgm*) malloc (sizeof(Pgm));
  if (new_node == NULL)
  {
    perror("Memory can't be allocated for new node");
    return NULL;
  } 
  else
  {
    new_node -> pgmlist = data;
    new_node -> next = NULL;
    return new_node;
  }
}



/* Execute the given command(s).

 * Note: The function currently only prints the command(s).
 * 
 * TODO: 
 * 1. Implement this function so that it executes the given command(s).
 * 2. Remove the debug printing before the final submission.
 */
void RunCommand(int parse_result, Command *cmd)
{
  DebugPrintCommand(parse_result, cmd);
  Pgm *pgm = cmd->pgm;
  char **pl = pgm->pgmlist;
  int input=0, output=1;
  if(cmd->rstdin != NULL)
  {
    input = open(cmd->rstdin, O_RDONLY);
  }
  if(cmd->rstdout != NULL) {
    output = open(cmd->rstdout, O_CREAT|O_WRONLY);
  }
  if(input<0 || output<0) {
    perror("Unable to open files provided");
    return;
  }
  if(pgm->next == NULL) {
    if(ownCmdHandler(pl) == 0)
      execArgs(pl, input, output, cmd->background);
  }
  else {
    // Reversing the pgm linked list since I didn't realize 
    // before implementing that parse stores in reverse
    Pgm *pgm0 = NULL, *temp = pgm;
    while(temp != NULL) {
      Pgm *new = create_node(temp->pgmlist);
      new->next = pgm0;
      pgm0 = new;
      temp = temp->next;
    }
    pgm = pgm0;

    int fd [2];
    while(pgm -> next != NULL) {
      char **pt = pgm->pgmlist;
      pipe(fd);
      if(ownCmdHandler(pt) == 0)
        execArgs(pt, input, fd[1], cmd->background);
      close(fd[1]);
      input = fd[0];
      pgm = pgm->next;
    }
    if(ownCmdHandler(pgm->pgmlist) == 0)
      execArgs(pgm->pgmlist, input, output, cmd->background);
  }
  return;
}

/* 
 * Print a Command structure as returned by parse on stdout. 
 * 
 * Helper function, no need to change. Might be useful to study as inpsiration.
 */
void DebugPrintCommand(int parse_result, Command *cmd)
{
  if (parse_result != 1) {
    printf("Parse ERROR\n");
    return;
  }
  printf("------------------------------\n");
  printf("Parse OK\n");
  printf("stdin:      %s\n", cmd->rstdin ? cmd->rstdin : "<none>");
  printf("stdout:     %s\n", cmd->rstdout ? cmd->rstdout : "<none>");
  printf("background: %s\n", cmd->background ? "true" : "false");
  printf("Pgms:\n");
  PrintPgm(cmd->pgm);
  printf("------------------------------\n");
}


/* Print a (linked) list of Pgm:s.
 * 
 * Helper function, no need to change. Might be useful to study as inpsiration.
 */
void PrintPgm(Pgm *p)
{
  if (p == NULL)
  {
    return;
  }
  else
  {
    char **pl = p->pgmlist;

    /* The list is in reversed order so print
     * it reversed to get right
     */
    PrintPgm(p->next);
    printf("            * [ ");
    while (*pl)
    {
      printf("%s ", *pl++);
    }
    printf("]\n");
  }
}


/* Strip whitespace from the start and end of a string. 
 *
 * Helper function, no need to change.
 */
void stripwhite(char *string)
{
  register int i = 0;

  while (isspace(string[i]))
  {
    i++;
  }

  if (i)
  {
    memmove(string, string + i, strlen(string + i) + 1);
  }

  i = strlen(string) - 1;
  while (i > 0 && isspace(string[i]))
  {
    i--;
  }

  string[++i] = '\0';
}
