#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

int main(){
    struct winsize w;
    char* text = " calmhertz was here ";

    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == -1) {
        perror("ioctl");
        return 1;
    }

    int n = w.ws_row/6;
    int hscale = 14;

    for(int i=0; i<n; i++){

        int full = hscale*n;
        int half = ((hscale*n)/2)-(strlen(text)/2);
        int text_row = n/2;
        int offset = ((w.ws_col-(full+(2*n)))/2)-1;

        for(int j=0; j<offset; j++){
            printf(" ");
        }

        for(int j=0; j<i; j++){
            printf(" ");
        }
        for(int j=0; j<n-i; j++){
            printf("*");
        }

        if(i==(text_row)){
            for(int j=0; j<half; j++){
                printf("*");
            }
            printf("\033[31m%s\033[0m", text);
            for(int j=0; j<half; j++){
                printf("*");
            }
        }
        else{
            for(int j=0; j<full; j++){
                printf("*");
            }
        }

        for(int j=0; j<n-i; j++){
            printf("*");
        }
        for(int j=0; j<i; j++){
            printf(" ");
        }
        printf("\n");

    }
}
