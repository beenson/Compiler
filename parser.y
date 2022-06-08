%{
	#include <ctype.h>
	#include <stdio.h>
	#include <string.h>
	#include <stdbool.h>
	#include <assert.h>
	#define MAXSTACK 1000 /*定義最大堆疊容量*/
	#define MAXQUEUE 1000 /*定義最大堆疊容量*/
	char *arrStack[MAXSTACK]; //暫存array的名字
	int arrStackTop = -1;
	typedef struct node;
	struct node *stack[MAXSTACK];  //堆疊的陣列宣告 
	struct node *queue[MAXQUEUE];  //queue的陣列宣告 
	int top = -1;	
	int head = 0, tail = 0;
	int size = 0;
	void yyerror(char *);
	int yylex(void);
	extern FILE *yyin;
	extern int linenum; //行數
	FILE *out; //輸出檔案
	FILE* myStream;
	int step = 0; //階層（用來輸出tab）
	int nodeQuantity = 0; //

	typedef struct node{
		int id;
		char name[15];
		struct node *children[4];
	}node;
	
	struct node* CreateNode(int id, char name[15]){
		struct node *n = malloc(sizeof(struct node));
		n->id = id + 1;
		strncpy(n->name, name, sizeof(n->name));
		//printf("id = %d, name = %s\n", n->id, n->name);
		nodeQuantity++;
		return n;
	}
	
	void SetChildren(struct node* node, struct node* children[4], int quantity){
		int count = 0;
		for (int i = 0; i < quantity; i++) {
			if (node->children[i] == NULL && children[i] != NULL)
				node->children[i] = children[i];
			count++;
		}
	}

	bool IsQueueEmpty(){
		return size <= 0;
	}

	void enqueue(struct node *node){
		if(tail>=MAXSTACK){
			printf("queue已滿,無法再加入\n");	
			yyerror("Full queue!!");
		}else{
			size++;
			queue[tail] = node;
			tail++;
		}

	}
	struct node * dequeue(){
		struct node * data;
		if(IsQueueEmpty()){
			printf("queue已空\n");
			yyerror("Empty queue!!");
		}
		data = queue[head];
		size--;
		head++;
		return data; 
	}
	/*判斷是否為空堆疊*/
	int isEmpty(){
		if(top==-1){
			return 1; 
		}
		else{
			return 0;
		}
	} 
	/*將指定的資料存入堆疊*/
	void push(struct node *node){
		if(top>=MAXSTACK){
			printf("堆疊已滿,無法再加入\n");	
			yyerror("Full stack!!");
		}else{
			top++;
			stack[top]=node;
		}
	} 
	/*從堆疊取出資料*/
	struct node * pop(){
		struct node * data;
		if (isEmpty()){
			printf("堆疊已空\n");
			yyerror("Empty stack!!");
		}
		data=stack[top];
		top--;
		return data; 
		
	}
	/*從堆疊print資料*/
	void printStack(){
		struct node * data;
		if (isEmpty()){
			printf("堆疊已空\n");
		}
		else{
			for (int i = 0; i < top; i++)
				if (stack[i] != NULL)
					printf("id = %d, name = %s\n", stack[i]->id, stack[i]->name);
		}
	}

%}

%token TEXT
%token DIGIT
%token EXP 
%token BOOLEAN
%token OPENBRACES CLOSEBRACES
%token OPSB CLSB
%token NIL
%token COLON
%token CMM
%token CH
%token NUMBER
%token END
%%

s 
: 
{
	fprintf(myStream, "<root>"); step++; 
} obj 
{
	fprintf(myStream, "</root>\n");
} END 
{
	
	struct node *eof = CreateNode(nodeQuantity, "EOF");	
	push(eof);
	struct node *start= CreateNode(nodeQuantity, "START");
	struct node *children[2];
	for (int i = 0; i < 2; i++)
		children[i] = pop();
	SetChildren(start, children, 2);
	push(start);
	printf("Syntax correct!!\n"); fclose(yyin); 
	printf("Total node = %d\n", nodeQuantity);
	//printStack();
	LevelOrder(pop());
	return 0;
}
;

obj
: 
{
	fprintf(myStream, "\n"); 
	//printStack();
} OPENBRACES 
{ 
	struct node *opbs = CreateNode(nodeQuantity, "{"); 
	push(opbs); 
	struct node *children[1];
	children[0] = pop();
	struct node *openbraces = CreateNode(nodeQuantity, "OPENBRACES");
	SetChildren(openbraces, children, 1);
	push(openbraces);
} pairlist CLOSEBRACES 
{
	struct node *clbs = CreateNode(nodeQuantity, "}"); 
	push(clbs); 
	struct node *children[3];
	children[0] = pop();
	struct node *closebraces = CreateNode(nodeQuantity, "CLOSEBRACES");
	SetChildren(closebraces, children, 1);
	push(closebraces);
	struct node *obj = CreateNode(nodeQuantity, "OBJECT");
	for (int i = 0; i < 3; i++){
		children[i] = pop();
			//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(obj, children, 3);
	push(obj);
}
;

pairlist 
: pair CMM 
{
	struct node *c= CreateNode(nodeQuantity, ","); 
	push(c); 	
	struct node *cmm = CreateNode(nodeQuantity, "CMM");
	struct node *children[1];
	children[0] = pop();
	SetChildren(cmm, children, 1);
	push(cmm);
} pairlist 
{
	struct node *pairList= CreateNode(nodeQuantity, "PAIR_LIST");
	struct node *children[3];	
	for (int i = 0; i < 3; i++){
		children[i] = pop();
			//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(pairList, children, 3);
	push(pairList);
}
| pair
{
	struct node *pairList= CreateNode(nodeQuantity, "PAIR_LIST");
	struct node *children[1];
	children[0] = pop();
	SetChildren(pairList, children, 1);
	push(pairList);
}
;

pair
: key NIL
{ 
	struct node *t = CreateNode(nodeQuantity, "null"); 
	push(t);
	struct node *pair = CreateNode(nodeQuantity, "PAIR");
	struct node *children[2];
	for (int i = 0; i < 2; i++)
		children[i] = pop();
	SetChildren(pair, children, 2);
	push(pair);
	PrintTab(step); 
	fprintf(myStream, "<%s />\n", $1);
} 
| key 
{
	PrintTab(step); 
	fprintf(myStream, "<%s>", $1);
} value
{
	struct node *pair = CreateNode(nodeQuantity, "PAIR");
	struct node *children[2];
	for (int i = 0; i < 2; i++) {
		children[i] = pop();
	}
	SetChildren(pair, children, 2);
	push(pair);
	fprintf(myStream, "</%s>\n", $1);
} 
| key 
{
	PrintTab(step); 
	fprintf(myStream, "<%s>", $1); 
	arrStack[++arrStackTop] = strdup($1);
} OPSB 
{
	struct node *opsb = CreateNode(nodeQuantity, "["); 
	push(opsb); 
} valuelist CLSB
{
	struct node *clsb = CreateNode(nodeQuantity, "]"); push(clsb); 
	struct node *pair = CreateNode(nodeQuantity, "PAIR");
	struct node *children[4];
	for (int i = 0; i < 4; i++)
		children[i] = pop();
	SetChildren(pair, children, 4);
	push(pair);
	fprintf(myStream, "</%s>\n", arrStack[arrStackTop--]);
} 
;

key
: TEXT COLON 
{
	struct node *t = CreateNode(nodeQuantity, $1); 
	push(t);
	struct node *children[2];
	children[0] = pop();
	struct node *text = CreateNode(nodeQuantity, "TEXT"); 
	SetChildren(text, children, 1);
	push(text);
	struct node *c = CreateNode(nodeQuantity, ":"); 
	push(c);
	children[0] = pop();
	struct node *colon = CreateNode(nodeQuantity, "COLON"); 
	SetChildren(colon, children, 1);
	push(colon);
	struct node *key = CreateNode(nodeQuantity, "KEY");
	for (int i = 0; i < 2; i++)
		children[i] = pop();
	SetChildren(key, children, 2);
	push(key);
}
;

value
:
{
	step++;
} 
obj 
{
	step--; 
	PrintTab(step); 
	struct node *children[1];
	struct node *value = CreateNode(nodeQuantity, "VALUE");
	children[0] = pop();
	SetChildren(value, children, 1);
	push(value);
}
| TEXT
{
	struct node *t = CreateNode(nodeQuantity, $1);
	push(t);
	struct node *children[1];
	children[0] = pop();
	struct node *text = CreateNode(nodeQuantity, "TEXT");
	SetChildren(text, children, 1);
	push(text);
	struct node *value = CreateNode(nodeQuantity, "VALUE");
	children[0] = pop();
	SetChildren(value, children, 1);
	push(value);
	fprintf(myStream, "%s", $1);
}
| NIL
{
	struct node *n = CreateNode(nodeQuantity, $1);
	push(n);
	struct node *nil = CreateNode(nodeQuantity, "NIL");
	struct node *children[1];
	children[0] = pop();
	SetChildren(nil, children, 1);
	push(nil);
	struct node *value = CreateNode(nodeQuantity, "VALUE");
	children[0] = pop();
	SetChildren(value, children, 1);
	push(value);
	fprintf(myStream, "%s", $1);
}
| NUMBER
{
	struct node *n = CreateNode(nodeQuantity, $1);
	push(n);
	struct node *number = CreateNode(nodeQuantity, "NUMBER");
	struct node *children[1];
	children[0] = pop();
	SetChildren(number, children, 1);
	push(number);
	struct node *value = CreateNode(nodeQuantity, "VALUE");
	children[0] = pop();
	SetChildren(value, children, 1);
	push(value);
	fprintf(myStream, "%s", $1);
}
| BOOLEAN
{
	struct node *b = CreateNode(nodeQuantity, $1);
	push(b);
	struct node *boolean = CreateNode(nodeQuantity, "BOOLEAN");
	struct node *children[1];
	children[0] = pop();
	SetChildren(boolean, children, 1);
	push(boolean);
	struct node *value = CreateNode(nodeQuantity, "VALUE");
	children[0] = pop();
	SetChildren(value, children, 1);
	push(value);
	fprintf(myStream, "%s", $1);
}
;

valuelist 
: value CMM 
{
	fprintf(myStream, "</%s>\n", arrStack[arrStackTop]); 
	PrintTab(step); 
	fprintf(myStream, "<%s>", arrStack[arrStackTop]); 
	struct node *c= CreateNode(nodeQuantity, ","); 
	push(c); 
	struct node *cmm = CreateNode(nodeQuantity, "CMM");
	struct node *children[1];
	children[0] = pop();
	SetChildren(cmm, children, 1);
	push(cmm);
} valuelist
{
	struct node *valueList= CreateNode(nodeQuantity, "VALUE_LIST");
	struct node *children[3];	
	for (int i = 0; i < 3; i++){
		children[i] = pop();
			//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(valueList, children, 3);
	push(valueList);
}
| value
{
	struct node *valueList= CreateNode(nodeQuantity, "VALUE_LIST");
	struct node *children[1];
	children[0] = pop();
	SetChildren(valueList, children, 1);
	push(valueList);
}
;


%%
//輸出tab
void PrintTab(int times){
	for (int i = 0; i < times; i++) {
    		fprintf(myStream, "\t");
	}
}

void PrintNode(struct node *current){
	if(current == NULL)
		return;
	printf("current -> %d %s\n", current->id, current->name);
	for (int i = 0; i < 4; i++)
		if(current->children[i] != NULL)
			printf("child -> %s ", current->children[i]->name);
	printf("\n");
	for (int i = 0; i < 4; i++)
		PrintNode(current->children[i]);
}

void LevelOrder(struct node *root){
	enqueue(root);                     // 把root作為level-order traversal之起點, 推進queue中
	printf("Parser tree:\n");
	int level[100];
	int queueStep = 0;
	while (!IsQueueEmpty()){                     // 若queue不是空的, 表示還有node沒有visiting
		struct node *current = dequeue();      // 取出先進入queue的node
		if(current->children[0] != NULL)        
			printf("%s -> ", current->name);   // 進行visiting
			for (int i = 3; i >= 0; i--) {
				if (current->children[i] != NULL){    // 若leftchild有資料, 將其推進queue
					printf("%s ", current->children[i]->name);		
					enqueue(current->children[i]);
				}
			
		}
		if(current->children[0] != NULL)        
			printf("\n");
	}
}

void yyerror(char* s){
	fprintf(stderr, "error: %s\n", s);
	printf("%s\nMistake line: %d\n", s, linenum);
	exit(1);
}

int yywrap(){
	return 1;
}

int main(int argc, char* argv[]){
	if ( argc == 2 )
		yyin = fopen(argv[1], "r");

	char* buffer = NULL;
	size_t bufferSize = 0;
	myStream = open_memstream(&buffer, &bufferSize);

	yyparse();
	
	fclose(myStream);
	argv[1][strlen(argv[1]) - 4] = 'x';
	argv[1][strlen(argv[1]) - 3] = 'm';
	argv[1][strlen(argv[1]) - 2] = 'l';
	argv[1][strlen(argv[1]) - 1] = '\0';
	out = fopen(argv[1], "w");
	fprintf(out, "%s", buffer);
	fclose(out);
	free(buffer);

	return 0;
}