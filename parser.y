%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

FILE *out;
int indent_level = 0;

void print_indent() {
    for(int i = 0; i < indent_level; i++) {
        fprintf(out, "    ");
    }
}

// C-Based Symbol Table Logic for Macros
#define MAX_SYMBOLS 100
char* symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

int lookup(char* name) {
    for(int i = 0; i < symbol_count; i++) {
        if(strcmp(symbol_table[i], name) == 0) {
            return 1;
        }
    }
    return 0;
}

void insert(char* name) {
    if(symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count++] = strdup(name);
    }
}

void translate_duration_num(char* dur, char* out_dur) {
    if(strcmp(dur, "quarter") == 0) strcpy(out_dur, "0.25");
    else if(strcmp(dur, "half") == 0) strcpy(out_dur, "0.5");
    else if(strcmp(dur, "whole") == 0) strcpy(out_dur, "1.0");
    else if(strcmp(dur, "eighth") == 0) strcpy(out_dur, "0.125");
    else strcpy(out_dur, "0.25"); // default
}

int rep_counter = 0;

%}

%union {
    int num;
    char* str;
}

%token TRACK TEMPO PLAY CHORD REPEAT DEFINE PLAYMACRO
%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET COMMA SEMICOLON
%token <num> NUMBER
%token <str> STRING NOTE_TOK IDENTIFIER
%token <str> QUARTER HALF WHOLE EIGHTH

%type <str> duration note_list

%%

program:
    track_def
    ;

track_def:
    TRACK STRING LBRACE {
        // SDT: write directly to the generated python file as soon as Track begins
        fprintf(out, "from music21 import stream, note, chord, tempo, instrument\n\n");
        fprintf(out, "s = stream.Part()\n");
        fprintf(out, "s.insert(0, instrument.Piano())\n\n");
    } statements RBRACE {
        fprintf(out, "\n# Save the generated midi\n");
        fprintf(out, "s.write('midi', fp='generated_audio.mid')\n");
        fprintf(out, "print('Successfully generated generated_audio.mid for track %s')\n", $2);
    }
    ;

statements:
    /* empty */
    | statements statement
    ;

statement:
    tempo_stmt
    | play_stmt
    | chord_stmt
    | repeat_stmt
    | define_stmt
    | playmacro_stmt
    ;

tempo_stmt:
    TEMPO NUMBER SEMICOLON {
        // Semantic Rule: Tempo must be between 1 and 300
        if($2 < 1 || $2 > 300) {
            fprintf(stderr, "Semantic Error at line %d: Tempo %d is out of range (1-300).\n", yylineno, $2);
            exit(1);
        }
        print_indent();
        fprintf(out, "s.append(tempo.MetronomeMark(number=%d))\n", $2);
    }
    ;

duration:
    QUARTER { $$ = $1; }
    | HALF { $$ = $1; }
    | WHOLE { $$ = $1; }
    | EIGHTH { $$ = $1; }
    ;

play_stmt:
    PLAY NOTE_TOK LPAREN duration RPAREN SEMICOLON {
        print_indent();
        // Emitting music21 note creation directly
        fprintf(out, "s.append(note.Note('%s', type='%s'))\n", $2, $4);
    }
    ;

note_list:
    NOTE_TOK {
        // Build comma separated string for python lists
        $$ = malloc(strlen($1) + 5);
        sprintf($$, "'%s'", $1);
    }
    | note_list COMMA NOTE_TOK {
        $$ = malloc(strlen($1) + strlen($3) + 6);
        sprintf($$, "%s, '%s'", $1, $3);
    }
    ;

chord_stmt:
    CHORD LBRACKET note_list RBRACKET LPAREN duration RPAREN SEMICOLON {
        print_indent();
        char dur_val[10];
        translate_duration_num($6, dur_val); // map named duration to numeric quarter units
        // Emit music21 chord creation
        fprintf(out, "s.append(chord.Chord([%s], quarterLength=%s))\n", $3, dur_val);
        free($3);
    }
    ;

repeat_stmt:
    REPEAT NUMBER LBRACE {
        print_indent();
        // Use a unique iterator for repeats (rep_counter allows nested loops comfortably)
        fprintf(out, "for _i%d in range(%d):\n", rep_counter++, $2);
        indent_level++;
        print_indent();
        // A pass statement ensures the loop block doesn't crash Python if the loop ends up empty
        fprintf(out, "pass\n");
    } statements RBRACE {
        // Manage logical indentation block structure
        indent_level--;
    }
    ;

define_stmt:
    DEFINE IDENTIFIER LBRACE {
        // Semantic Check: Check for Redefinition
        if(lookup($2)) {
            fprintf(stderr, "Semantic Error at line %d: Macro '%s' already defined.\n", yylineno, $2);
            exit(1);
        }
        insert($2); // Store into our C Symbol Table
        print_indent();
        fprintf(out, "def %s():\n", $2);
        indent_level++;
        print_indent();
        fprintf(out, "pass\n"); // Python dummy block so we don't encounter IndentationError
    } statements RBRACE {
        indent_level--;
    }
    ;

playmacro_stmt:
    PLAYMACRO IDENTIFIER SEMICOLON {
        // Semantic Check: Check if declared
        if(!lookup($2)) {
            fprintf(stderr, "Semantic Error at line %d: Undeclared Macro '%s'.\n", yylineno, $2);
            exit(1);
        }
        print_indent();
        fprintf(out, "%s()\n", $2);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}

int main(int argc, char** argv) {
    if(argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if(!f) {
            perror("Error opening input file");
            return 1;
        }
        yyin = f;
    } else {
        fprintf(stderr, "Usage: %s <input_file.mstr>\n", argv[0]);
        return 1;
    }
    
    // Open target file for generation
    out = fopen("generated_audio.py", "w");
    if(!out) {
        perror("Error opening output file");
        return 1;
    }
    
    int parse_result = yyparse();
    
    if(out) {
        fclose(out);
    }
    
    if (parse_result == 0) {
        printf("Compilation successful! Generating audio behind the scenes...\n");
        
        /* AUTOMATICALLY RUN THE PYTHON SCRIPT */
        system("python3 generated_audio.py");
        
    } else {
        printf("Compilation failed.\n");
        remove("generated_audio.py"); 
    }
    
    return parse_result;
}
