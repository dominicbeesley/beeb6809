/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "grammar.y"

/*

asm6809, a Motorola 6809 cross assembler
Copyright 2013-2017 Ciaran Anscomb

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

*/

#include "config.h"

#include <stdio.h>
#include <string.h>

#include "c-strcase.h"

#include "error.h"
#include "eval.h"
#include "node.h"
#include "program.h"
#include "register.h"
#include "slist.h"

static void raise_error(void);
static void yyerror(const char *);
void yylex_destroy(void);
int yylex(void);
char *lex_fetch_line(void);
void lex_free_all(void);

extern FILE *yyin;
static struct prog_ctx *cur_ctx = NULL;

struct prog *grammar_parse_file(const char *filename);

static void check_end_opcode(struct prog_line *line);

#line 113 "grammar.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Use api.header.include to #include this header
   instead of duplicating it here.  */
#ifndef YY_YY_GRAMMAR_H_INCLUDED
# define YY_YY_GRAMMAR_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    WS = 258,                      /* WS  */
    ID = 259,                      /* ID  */
    INTERP = 260,                  /* INTERP  */
    FLOAT = 261,                   /* FLOAT  */
    INTEGER = 262,                 /* INTEGER  */
    BACKREF = 263,                 /* BACKREF  */
    FWDREF = 264,                  /* FWDREF  */
    REGISTER = 265,                /* REGISTER  */
    TEXT = 266,                    /* TEXT  */
    SHL = 267,                     /* SHL  */
    SHR = 268,                     /* SHR  */
    LE = 269,                      /* LE  */
    GE = 270,                      /* GE  */
    EQ = 271,                      /* EQ  */
    NE = 272,                      /* NE  */
    LOR = 273,                     /* LOR  */
    LAND = 274,                    /* LAND  */
    DELIM = 275,                   /* DELIM  */
    DEC2 = 276,                    /* DEC2  */
    INC2 = 277,                    /* INC2  */
    UMINUS = 278                   /* UMINUS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define WS 258
#define ID 259
#define INTERP 260
#define FLOAT 261
#define INTEGER 262
#define BACKREF 263
#define FWDREF 264
#define REGISTER 265
#define TEXT 266
#define SHL 267
#define SHR 268
#define LE 269
#define GE 270
#define EQ 271
#define NE 272
#define LOR 273
#define LAND 274
#define DELIM 275
#define DEC2 276
#define INC2 277
#define UMINUS 278

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 43 "grammar.y"

	int as_token;
	int64_t as_int;
	double as_float;
	char *as_string;
	enum reg_id as_reg;
	struct node *as_node;
	struct prog_line *as_line;
	struct slist *as_list;
	

#line 224 "grammar.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_GRAMMAR_H_INCLUDED  */
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_WS = 3,                         /* WS  */
  YYSYMBOL_ID = 4,                         /* ID  */
  YYSYMBOL_INTERP = 5,                     /* INTERP  */
  YYSYMBOL_FLOAT = 6,                      /* FLOAT  */
  YYSYMBOL_INTEGER = 7,                    /* INTEGER  */
  YYSYMBOL_BACKREF = 8,                    /* BACKREF  */
  YYSYMBOL_FWDREF = 9,                     /* FWDREF  */
  YYSYMBOL_REGISTER = 10,                  /* REGISTER  */
  YYSYMBOL_TEXT = 11,                      /* TEXT  */
  YYSYMBOL_SHL = 12,                       /* SHL  */
  YYSYMBOL_SHR = 13,                       /* SHR  */
  YYSYMBOL_LE = 14,                        /* LE  */
  YYSYMBOL_GE = 15,                        /* GE  */
  YYSYMBOL_EQ = 16,                        /* EQ  */
  YYSYMBOL_NE = 17,                        /* NE  */
  YYSYMBOL_LOR = 18,                       /* LOR  */
  YYSYMBOL_LAND = 19,                      /* LAND  */
  YYSYMBOL_DELIM = 20,                     /* DELIM  */
  YYSYMBOL_DEC2 = 21,                      /* DEC2  */
  YYSYMBOL_INC2 = 22,                      /* INC2  */
  YYSYMBOL_23_ = 23,                       /* '?'  */
  YYSYMBOL_24_ = 24,                       /* ':'  */
  YYSYMBOL_25_ = 25,                       /* '|'  */
  YYSYMBOL_26_ = 26,                       /* '^'  */
  YYSYMBOL_27_ = 27,                       /* '&'  */
  YYSYMBOL_28_ = 28,                       /* '<'  */
  YYSYMBOL_29_ = 29,                       /* '>'  */
  YYSYMBOL_30_ = 30,                       /* '+'  */
  YYSYMBOL_31_ = 31,                       /* '-'  */
  YYSYMBOL_32_ = 32,                       /* '*'  */
  YYSYMBOL_33_ = 33,                       /* '/'  */
  YYSYMBOL_34_ = 34,                       /* '%'  */
  YYSYMBOL_UMINUS = 35,                    /* UMINUS  */
  YYSYMBOL_36_ = 36,                       /* '!'  */
  YYSYMBOL_37_ = 37,                       /* '~'  */
  YYSYMBOL_38_ = 38,                       /* '('  */
  YYSYMBOL_39_ = 39,                       /* ')'  */
  YYSYMBOL_40_n_ = 40,                     /* '\n'  */
  YYSYMBOL_41_ = 41,                       /* ','  */
  YYSYMBOL_42_ = 42,                       /* '['  */
  YYSYMBOL_43_ = 43,                       /* ']'  */
  YYSYMBOL_44_ = 44,                       /* '#'  */
  YYSYMBOL_YYACCEPT = 45,                  /* $accept  */
  YYSYMBOL_program = 46,                   /* program  */
  YYSYMBOL_line = 47,                      /* line  */
  YYSYMBOL_label = 48,                     /* label  */
  YYSYMBOL_id = 49,                        /* id  */
  YYSYMBOL_idlist = 50,                    /* idlist  */
  YYSYMBOL_idpart = 51,                    /* idpart  */
  YYSYMBOL_arglist = 52,                   /* arglist  */
  YYSYMBOL_arg = 53,                       /* arg  */
  YYSYMBOL_reg = 54,                       /* reg  */
  YYSYMBOL_expr = 55,                      /* expr  */
  YYSYMBOL_string = 56,                    /* string  */
  YYSYMBOL_strlist = 57,                   /* strlist  */
  YYSYMBOL_strpart = 58                    /* strpart  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   327

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  45
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  14
/* YYNRULES -- Number of rules.  */
#define YYNRULES  71
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  114

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   278


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      40,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    36,     2,    44,     2,    34,    27,     2,
      38,    39,    32,    30,    41,    31,     2,    33,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    24,     2,
      28,     2,    29,    23,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    42,     2,    43,    26,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,    25,     2,    37,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    35
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,    92,    92,    93,    94,    97,    98,    99,   100,   101,
     104,   105,   106,   109,   112,   113,   116,   117,   120,   121,
     124,   125,   126,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,   141,   144,   145,   146,   147,
     148,   149,   150,   151,   152,   153,   154,   155,   156,   157,
     158,   159,   160,   161,   162,   163,   164,   165,   166,   167,
     168,   169,   170,   171,   172,   173,   174,   177,   180,   181,
     184,   185
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "WS", "ID", "INTERP",
  "FLOAT", "INTEGER", "BACKREF", "FWDREF", "REGISTER", "TEXT", "SHL",
  "SHR", "LE", "GE", "EQ", "NE", "LOR", "LAND", "DELIM", "DEC2", "INC2",
  "'?'", "':'", "'|'", "'^'", "'&'", "'<'", "'>'", "'+'", "'-'", "'*'",
  "'/'", "'%'", "UMINUS", "'!'", "'~'", "'('", "')'", "'\\n'", "','",
  "'['", "']'", "'#'", "$accept", "program", "line", "label", "id",
  "idlist", "idpart", "arglist", "arg", "reg", "expr", "string", "strlist",
  "strpart", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-27)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-11)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     -27,    21,   -27,   -25,   -27,   -27,   -27,   -27,    -1,   -27,
      79,   -27,   -27,    79,   -27,   -27,    30,   -22,    59,   -27,
     -27,   -27,   -27,   -27,   -27,   -27,   109,     2,    17,   109,
     109,   109,   100,   -27,   109,   109,   109,    59,   109,   -27,
       0,   -27,    51,   187,   -27,   109,   187,   -27,   -27,     9,
     -27,   -27,   187,   187,   -27,   -27,   -27,   -27,   -27,   136,
     -11,   187,    22,   -27,    59,   -27,   -27,   -27,   109,   109,
     109,   109,   109,   109,   109,   109,   109,   109,   109,   109,
     109,   109,   109,   109,   109,   109,   109,   -27,   -27,   -27,
     -27,   -27,   -27,    44,    44,   293,   293,     4,     4,   210,
     233,   164,   256,   264,   287,   293,   293,    89,    89,   -27,
     -27,   -27,   109,   187
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       2,     0,     1,     0,    16,    17,    11,     3,     0,    12,
      13,    14,     4,     0,     9,    15,     0,     0,    20,     7,
       8,    61,    60,    62,    63,    35,     0,     0,     0,    26,
      27,     0,     0,    64,     0,     0,     0,    20,     0,    66,
       0,    18,    33,    34,    65,     0,    23,    71,    70,     0,
      68,    31,    24,    25,    38,    30,    37,    40,    39,     0,
       0,    22,     0,     5,    20,    29,    28,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    67,    69,    36,
      21,     6,    19,    46,    47,    49,    51,    52,    53,    58,
      57,     0,    56,    55,    54,    48,    50,    44,    45,    41,
      42,    43,     0,    59
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -27,   -27,   -27,   -27,    10,   -27,    62,    48,    28,    66,
     -26,   -27,   -27,    50
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     7,     8,    39,    10,    11,    40,    41,    42,
      43,    44,    49,    50
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      46,    62,    13,    52,    53,    54,    56,    47,    57,    58,
      59,     9,    61,    48,    47,    12,    68,    69,    20,    56,
      48,     2,     3,    16,   -10,     4,     5,    25,     6,    87,
      64,    17,    90,    18,    82,    83,    84,    85,    86,    14,
      63,    64,    93,    94,    95,    96,    97,    98,    99,   100,
     101,   102,   103,   104,   105,   106,   107,   108,   109,   110,
     111,   -10,    91,     4,     5,    21,    22,    23,    24,    25,
      19,    26,    15,    65,    82,    83,    84,    85,    86,    27,
      28,    66,    67,     4,     5,    60,   113,    29,    30,    31,
      32,    33,    92,     0,    51,    34,    35,    36,    55,    88,
       0,    37,     0,    38,     4,     5,    21,    22,    23,    24,
      25,     0,     0,     4,     5,    21,    22,    23,    24,     0,
      27,    84,    85,    86,     0,     0,     0,     0,     0,    27,
      31,    45,    33,     0,     0,     0,    34,    35,    36,    31,
      45,    33,     0,     0,     0,    34,    35,    36,    68,    69,
      70,    71,    72,    73,    74,    75,     0,     0,     0,    76,
       0,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      86,     0,     0,     0,     0,    89,    68,    69,    70,    71,
      72,    73,    74,    75,     0,     0,     0,    76,   112,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    86,    68,
      69,    70,    71,    72,    73,    74,    75,     0,     0,     0,
      76,     0,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    68,    69,    70,    71,    72,    73,     0,    75,
       0,     0,     0,     0,     0,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    68,    69,    70,    71,    72,
      73,     0,     0,     0,     0,     0,     0,     0,    77,    78,
      79,    80,    81,    82,    83,    84,    85,    86,    68,    69,
      70,    71,    72,    73,     0,     0,    68,    69,    70,    71,
      72,    73,    78,    79,    80,    81,    82,    83,    84,    85,
      86,    79,    80,    81,    82,    83,    84,    85,    86,    68,
      69,    70,    71,    72,    73,    68,    69,     0,     0,    72,
      73,     0,     0,     0,     0,    80,    81,    82,    83,    84,
      85,    86,     0,    82,    83,    84,    85,    86
};

static const yytype_int8 yycheck[] =
{
      26,     1,     3,    29,    30,    31,    32,     5,    34,    35,
      36,     1,    38,    11,     5,    40,    12,    13,    40,    45,
      11,     0,     1,    13,     3,     4,     5,    10,     7,    20,
      41,     1,    43,     3,    30,    31,    32,    33,    34,    40,
      40,    41,    68,    69,    70,    71,    72,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      86,    40,    40,     4,     5,     6,     7,     8,     9,    10,
      40,    12,    10,    22,    30,    31,    32,    33,    34,    20,
      21,    30,    31,     4,     5,    37,   112,    28,    29,    30,
      31,    32,    64,    -1,    28,    36,    37,    38,    32,    49,
      -1,    42,    -1,    44,     4,     5,     6,     7,     8,     9,
      10,    -1,    -1,     4,     5,     6,     7,     8,     9,    -1,
      20,    32,    33,    34,    -1,    -1,    -1,    -1,    -1,    20,
      30,    31,    32,    -1,    -1,    -1,    36,    37,    38,    30,
      31,    32,    -1,    -1,    -1,    36,    37,    38,    12,    13,
      14,    15,    16,    17,    18,    19,    -1,    -1,    -1,    23,
      -1,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    -1,    -1,    -1,    -1,    39,    12,    13,    14,    15,
      16,    17,    18,    19,    -1,    -1,    -1,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    12,
      13,    14,    15,    16,    17,    18,    19,    -1,    -1,    -1,
      23,    -1,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    12,    13,    14,    15,    16,    17,    -1,    19,
      -1,    -1,    -1,    -1,    -1,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    12,    13,    14,    15,    16,
      17,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    12,    13,
      14,    15,    16,    17,    -1,    -1,    12,    13,    14,    15,
      16,    17,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    27,    28,    29,    30,    31,    32,    33,    34,    12,
      13,    14,    15,    16,    17,    12,    13,    -1,    -1,    16,
      17,    -1,    -1,    -1,    -1,    28,    29,    30,    31,    32,
      33,    34,    -1,    30,    31,    32,    33,    34
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    46,     0,     1,     4,     5,     7,    47,    48,    49,
      50,    51,    40,     3,    40,    51,    49,     1,     3,    40,
      40,     6,     7,     8,     9,    10,    12,    20,    21,    28,
      29,    30,    31,    32,    36,    37,    38,    42,    44,    49,
      52,    53,    54,    55,    56,    31,    55,     5,    11,    57,
      58,    54,    55,    55,    55,    54,    55,    55,    55,    55,
      52,    55,     1,    40,    41,    22,    30,    31,    12,    13,
      14,    15,    16,    17,    18,    19,    23,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    20,    58,    39,
      43,    40,    53,    55,    55,    55,    55,    55,    55,    55,
      55,    55,    55,    55,    55,    55,    55,    55,    55,    55,
      55,    55,    24,    55
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    45,    46,    46,    46,    47,    47,    47,    47,    47,
      48,    48,    48,    49,    50,    50,    51,    51,    52,    52,
      53,    53,    53,    53,    53,    53,    53,    53,    53,    53,
      53,    53,    53,    53,    53,    54,    55,    55,    55,    55,
      55,    55,    55,    55,    55,    55,    55,    55,    55,    55,
      55,    55,    55,    55,    55,    55,    55,    55,    55,    55,
      55,    55,    55,    55,    55,    55,    55,    56,    57,    57,
      58,    58
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     0,     2,     3,     6,     7,     4,     5,     2,
       0,     1,     1,     1,     1,     2,     1,     1,     1,     3,
       0,     3,     2,     2,     2,     2,     1,     1,     2,     2,
       2,     2,     2,     1,     1,     1,     3,     2,     2,     2,
       2,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     5,
       1,     1,     1,     1,     1,     1,     1,     3,     1,     2,
       1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  switch (yykind)
    {
    case YYSYMBOL_ID: /* ID  */
#line 66 "grammar.y"
            { free(((*yyvaluep).as_string)); }
#line 1115 "grammar.c"
        break;

    case YYSYMBOL_INTERP: /* INTERP  */
#line 66 "grammar.y"
            { free(((*yyvaluep).as_string)); }
#line 1121 "grammar.c"
        break;

    case YYSYMBOL_TEXT: /* TEXT  */
#line 66 "grammar.y"
            { free(((*yyvaluep).as_string)); }
#line 1127 "grammar.c"
        break;

      default:
        break;
    }
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 3: /* program: program line  */
#line 93 "grammar.y"
                        { prog_line_set_text((yyvsp[0].as_line), lex_fetch_line()); prog_ctx_add_line(cur_ctx, (yyvsp[0].as_line)); check_end_opcode((yyvsp[0].as_line)); }
#line 1397 "grammar.c"
    break;

  case 4: /* program: program error '\n'  */
#line 94 "grammar.y"
                                { raise_error(); yyerrok; }
#line 1403 "grammar.c"
    break;

  case 5: /* line: label WS id WS arglist '\n'  */
#line 97 "grammar.y"
                                        { (yyval.as_line) = prog_line_new((yyvsp[-5].as_node), (yyvsp[-3].as_node), (yyvsp[-1].as_node)); }
#line 1409 "grammar.c"
    break;

  case 6: /* line: label WS id WS arglist error '\n'  */
#line 98 "grammar.y"
                                                { (yyval.as_line) = prog_line_new((yyvsp[-6].as_node), (yyvsp[-4].as_node), (yyvsp[-2].as_node)); }
#line 1415 "grammar.c"
    break;

  case 7: /* line: label WS id '\n'  */
#line 99 "grammar.y"
                                        { (yyval.as_line) = prog_line_new((yyvsp[-3].as_node), (yyvsp[-1].as_node), NULL); }
#line 1421 "grammar.c"
    break;

  case 8: /* line: label WS id error '\n'  */
#line 100 "grammar.y"
                                        { (yyval.as_line) = prog_line_new((yyvsp[-4].as_node), (yyvsp[-2].as_node), NULL); }
#line 1427 "grammar.c"
    break;

  case 9: /* line: label '\n'  */
#line 101 "grammar.y"
                                        { (yyval.as_line) = prog_line_new((yyvsp[-1].as_node), NULL, NULL); }
#line 1433 "grammar.c"
    break;

  case 10: /* label: %empty  */
#line 104 "grammar.y"
                                { (yyval.as_node) = NULL; }
#line 1439 "grammar.c"
    break;

  case 11: /* label: INTEGER  */
#line 105 "grammar.y"
                                { (yyval.as_node) = node_new_int((yyvsp[0].as_int)); }
#line 1445 "grammar.c"
    break;

  case 12: /* label: id  */
#line 106 "grammar.y"
                                { (yyval.as_node) = (yyvsp[0].as_node); }
#line 1451 "grammar.c"
    break;

  case 13: /* id: idlist  */
#line 109 "grammar.y"
                                { (yyval.as_node) = node_new_id((yyvsp[0].as_list)); }
#line 1457 "grammar.c"
    break;

  case 14: /* idlist: idpart  */
#line 112 "grammar.y"
                                { (yyval.as_list) = slist_append(NULL, (yyvsp[0].as_node)); }
#line 1463 "grammar.c"
    break;

  case 15: /* idlist: idlist idpart  */
#line 113 "grammar.y"
                                { (yyval.as_list) = slist_append((yyvsp[-1].as_list), (yyvsp[0].as_node)); }
#line 1469 "grammar.c"
    break;

  case 16: /* idpart: ID  */
#line 116 "grammar.y"
                                { (yyval.as_node) = node_new_string((yyvsp[0].as_string)); }
#line 1475 "grammar.c"
    break;

  case 17: /* idpart: INTERP  */
#line 117 "grammar.y"
                                { (yyval.as_node) = node_new_interp((yyvsp[0].as_string)); }
#line 1481 "grammar.c"
    break;

  case 18: /* arglist: arg  */
#line 120 "grammar.y"
                                { (yyval.as_node) = node_array_push(NULL, (yyvsp[0].as_node)); }
#line 1487 "grammar.c"
    break;

  case 19: /* arglist: arglist ',' arg  */
#line 121 "grammar.y"
                                { (yyval.as_node) = node_array_push((yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1493 "grammar.c"
    break;

  case 20: /* arg: %empty  */
#line 124 "grammar.y"
                                { (yyval.as_node) = node_new_empty(); }
#line 1499 "grammar.c"
    break;

  case 21: /* arg: '[' arglist ']'  */
#line 125 "grammar.y"
                                { (yyval.as_node) = (yyvsp[-1].as_node); }
#line 1505 "grammar.c"
    break;

  case 22: /* arg: '#' expr  */
#line 126 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_immediate); }
#line 1511 "grammar.c"
    break;

  case 23: /* arg: SHL expr  */
#line 127 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_5bit); }
#line 1517 "grammar.c"
    break;

  case 24: /* arg: '<' expr  */
#line 128 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_8bit); }
#line 1523 "grammar.c"
    break;

  case 25: /* arg: '>' expr  */
#line 129 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_16bit); }
#line 1529 "grammar.c"
    break;

  case 26: /* arg: '<'  */
#line 130 "grammar.y"
                                { (yyval.as_node) = node_new_backref(0); }
#line 1535 "grammar.c"
    break;

  case 27: /* arg: '>'  */
#line 131 "grammar.y"
                                { (yyval.as_node) = node_new_fwdref(0); }
#line 1541 "grammar.c"
    break;

  case 28: /* arg: reg '+'  */
#line 132 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[-1].as_node), node_attr_postinc); }
#line 1547 "grammar.c"
    break;

  case 29: /* arg: reg INC2  */
#line 133 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[-1].as_node), node_attr_postinc2); }
#line 1553 "grammar.c"
    break;

  case 30: /* arg: '-' reg  */
#line 134 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_predec); }
#line 1559 "grammar.c"
    break;

  case 31: /* arg: DEC2 reg  */
#line 135 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[0].as_node), node_attr_predec2); }
#line 1565 "grammar.c"
    break;

  case 32: /* arg: reg '-'  */
#line 136 "grammar.y"
                                { (yyval.as_node) = node_set_attr((yyvsp[-1].as_node), node_attr_postdec); }
#line 1571 "grammar.c"
    break;

  case 33: /* arg: reg  */
#line 137 "grammar.y"
                                { (yyval.as_node) = (yyvsp[0].as_node); }
#line 1577 "grammar.c"
    break;

  case 34: /* arg: expr  */
#line 138 "grammar.y"
                                { (yyval.as_node) = (yyvsp[0].as_node); }
#line 1583 "grammar.c"
    break;

  case 35: /* reg: REGISTER  */
#line 141 "grammar.y"
                                { (yyval.as_node) = node_new_reg((yyvsp[0].as_reg)); }
#line 1589 "grammar.c"
    break;

  case 36: /* expr: '(' expr ')'  */
#line 144 "grammar.y"
                                { (yyval.as_node) = (yyvsp[-1].as_node); }
#line 1595 "grammar.c"
    break;

  case 37: /* expr: '-' expr  */
#line 145 "grammar.y"
                                { (yyval.as_node) = node_new_oper_1('-', (yyvsp[0].as_node)); }
#line 1601 "grammar.c"
    break;

  case 38: /* expr: '+' expr  */
#line 146 "grammar.y"
                                { (yyval.as_node) = node_new_oper_1('+', (yyvsp[0].as_node)); }
#line 1607 "grammar.c"
    break;

  case 39: /* expr: '~' expr  */
#line 147 "grammar.y"
                                { (yyval.as_node) = node_new_oper_1('~', (yyvsp[0].as_node)); }
#line 1613 "grammar.c"
    break;

  case 40: /* expr: '!' expr  */
#line 148 "grammar.y"
                                { (yyval.as_node) = node_new_oper_1('!', (yyvsp[0].as_node)); }
#line 1619 "grammar.c"
    break;

  case 41: /* expr: expr '*' expr  */
#line 149 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('*', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1625 "grammar.c"
    break;

  case 42: /* expr: expr '/' expr  */
#line 150 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('/', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1631 "grammar.c"
    break;

  case 43: /* expr: expr '%' expr  */
#line 151 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('%', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1637 "grammar.c"
    break;

  case 44: /* expr: expr '+' expr  */
#line 152 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('+', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1643 "grammar.c"
    break;

  case 45: /* expr: expr '-' expr  */
#line 153 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('-', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1649 "grammar.c"
    break;

  case 46: /* expr: expr SHL expr  */
#line 154 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(SHL, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1655 "grammar.c"
    break;

  case 47: /* expr: expr SHR expr  */
#line 155 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(SHR, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1661 "grammar.c"
    break;

  case 48: /* expr: expr '<' expr  */
#line 156 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('<', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1667 "grammar.c"
    break;

  case 49: /* expr: expr LE expr  */
#line 157 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(LE, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1673 "grammar.c"
    break;

  case 50: /* expr: expr '>' expr  */
#line 158 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('>', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1679 "grammar.c"
    break;

  case 51: /* expr: expr GE expr  */
#line 159 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(GE, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1685 "grammar.c"
    break;

  case 52: /* expr: expr EQ expr  */
#line 160 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(EQ, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1691 "grammar.c"
    break;

  case 53: /* expr: expr NE expr  */
#line 161 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(NE, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1697 "grammar.c"
    break;

  case 54: /* expr: expr '&' expr  */
#line 162 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('&', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1703 "grammar.c"
    break;

  case 55: /* expr: expr '^' expr  */
#line 163 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('^', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1709 "grammar.c"
    break;

  case 56: /* expr: expr '|' expr  */
#line 164 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2('|', (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1715 "grammar.c"
    break;

  case 57: /* expr: expr LAND expr  */
#line 165 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(LAND, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1721 "grammar.c"
    break;

  case 58: /* expr: expr LOR expr  */
#line 166 "grammar.y"
                                { (yyval.as_node) = node_new_oper_2(LOR, (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1727 "grammar.c"
    break;

  case 59: /* expr: expr '?' expr ':' expr  */
#line 167 "grammar.y"
                                        { (yyval.as_node) = node_new_oper_3('?', (yyvsp[-4].as_node), (yyvsp[-2].as_node), (yyvsp[0].as_node)); }
#line 1733 "grammar.c"
    break;

  case 60: /* expr: INTEGER  */
#line 168 "grammar.y"
                                { (yyval.as_node) = node_new_int((yyvsp[0].as_int)); }
#line 1739 "grammar.c"
    break;

  case 61: /* expr: FLOAT  */
#line 169 "grammar.y"
                                { (yyval.as_node) = node_new_float((yyvsp[0].as_float)); }
#line 1745 "grammar.c"
    break;

  case 62: /* expr: BACKREF  */
#line 170 "grammar.y"
                                { (yyval.as_node) = node_new_backref((yyvsp[0].as_int)); }
#line 1751 "grammar.c"
    break;

  case 63: /* expr: FWDREF  */
#line 171 "grammar.y"
                                { (yyval.as_node) = node_new_fwdref((yyvsp[0].as_int)); }
#line 1757 "grammar.c"
    break;

  case 64: /* expr: '*'  */
#line 172 "grammar.y"
                                { (yyval.as_node) = node_new_pc(); }
#line 1763 "grammar.c"
    break;

  case 65: /* expr: string  */
#line 173 "grammar.y"
                                { (yyval.as_node) = (yyvsp[0].as_node); }
#line 1769 "grammar.c"
    break;

  case 66: /* expr: id  */
#line 174 "grammar.y"
                                { (yyval.as_node) = (yyvsp[0].as_node); }
#line 1775 "grammar.c"
    break;

  case 67: /* string: DELIM strlist DELIM  */
#line 177 "grammar.y"
                                { (yyval.as_node) = node_new_text((yyvsp[-1].as_list)); }
#line 1781 "grammar.c"
    break;

  case 68: /* strlist: strpart  */
#line 180 "grammar.y"
                                { (yyval.as_list) = slist_append(NULL, (yyvsp[0].as_node)); }
#line 1787 "grammar.c"
    break;

  case 69: /* strlist: strlist strpart  */
#line 181 "grammar.y"
                                { (yyval.as_list) = slist_append((yyvsp[-1].as_list), (yyvsp[0].as_node)); }
#line 1793 "grammar.c"
    break;

  case 70: /* strpart: TEXT  */
#line 184 "grammar.y"
                                { (yyval.as_node) = node_new_string((yyvsp[0].as_string)); }
#line 1799 "grammar.c"
    break;

  case 71: /* strpart: INTERP  */
#line 185 "grammar.y"
                                { (yyval.as_node) = node_new_interp((yyvsp[0].as_string)); }
#line 1805 "grammar.c"
    break;


#line 1809 "grammar.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 188 "grammar.y"


static void raise_error(void) {
	// discard line with error - going to fail anyway
	char *l = lex_fetch_line();
	free(l);
	cur_ctx->line_number++;
	error(error_type_syntax, "");
}

static void yyerror(const char *s) {
	(void)s;
}

struct prog *grammar_parse_file(const char *filename) {
	yyin = fopen(filename, "r");
	if (!yyin) {
		error(error_type_fatal, "file not found: %s", filename);
		return NULL;
	}
	struct prog *prog = prog_new(prog_type_file, filename);
	cur_ctx = prog_ctx_new(prog);
	yyparse();
	prog_ctx_free(cur_ctx);
	cur_ctx = NULL;
	if (yyin)
		fclose(yyin);
	lex_free_all();
	return prog;
}

static void check_end_opcode(struct prog_line *line) {
	struct node *n = eval_string(line->opcode);
	if (n) {
		if (0 == c_strcasecmp("end", n->data.as_string)) {
			fclose(yyin);
			yyin = NULL;
		}
		node_free(n);
	}
}
