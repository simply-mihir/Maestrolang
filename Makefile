CC = gcc
LEX = flex
BISON = bison
CFLAGS = -Wall -Wextra

maestro: parser.tab.c lex.yy.c
	$(CC) -o maestro parser.tab.c lex.yy.c

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d parser.y

lex.yy.c: lexer.l parser.tab.h
	$(LEX) lexer.l

clean:
	rm -f maestro parser.tab.c parser.tab.h lex.yy.c generated_audio.py generated_audio.mid
