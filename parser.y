%{
	#include <ctype.h>
	#include <stdio.h>
	#include <string.h>
	#include <stdbool.h>
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
	FILE *myStream;
	int step = 0; //階層（用來輸出tab）
	int nodeQuantity = 0; //
	
	//用來存放每個token的資訊，用以建構parser tree
	typedef struct node{
		int id; //第幾個生成
		char name[15]; //內容
		struct node *children[4]; //子節點
	}node;
	
	//Create節點，需傳入id與name
	struct node* CreateNode(int id, char name[15]){
		struct node *n = malloc(sizeof(struct node));
		n->id = id + 1;
		strncpy(n->name, name, sizeof(n->name));
		//printf("id = %d, name = %s\n", n->id, n->name);
		nodeQuantity++;
		return n;
	}
	
	//設定某個node的children
	void SetChildren(struct node* node, struct node* children[4], int quantity){
		int count = 0;
		for (int i = 0; i < quantity; i++) {
			if (node->children[i] == NULL && children[i] != NULL)
				node->children[i] = children[i];
			count++;
		}
	}
	
	//回傳queue是否為空
	bool IsQueueEmpty(){
		return size <= 0;
	}

	//將node放進queue的尾巴
	void enqueue(struct node *node){
		if(tail>=MAXSTACK){
			printf("queue已滿，無法再加入\n");	
			yyerror("Queue is full!!");
		}else{
			size++;
			queue[tail] = node;
			tail++;
		}

	}
	
	//將queue裡面的最後一個node拿出來
	struct node * dequeue(){
		struct node * data;
		if(IsQueueEmpty()){
			printf("queue已空\n");
			yyerror("Queue is empty!!");
		}
		data = queue[head];
		size--;
		head++;
		return data; 
	}
	
	//判斷是否為空堆疊
	int isEmpty(){
		if(top==-1){
			return 1; 
		}
		else{
			return 0;
		}
	} 
	
	//將指定的資料存入堆疊
	void push(struct node *node){
		if(top>=MAXSTACK){
			printf("堆疊已滿,無法再加入\n");	
			yyerror("Stack is full!!");
		}else{
			top++;
			stack[top]=node;
		}
	} 
	
	//從堆疊取出資料
	struct node * pop(){
		struct node * data;
		if (isEmpty()){
			printf("堆疊已空\n");
			yyerror("Stack is full!!");
		}
		data=stack[top];
		top--;
		return data; 
		
	}
	
	//從堆疊print資料
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
	fprintf(myStream, "<root>");
	step++; //多一次縮排
} obj END 
{
	struct node *eof = CreateNode(nodeQuantity, "EOF");	//建立node（EOF）
	push(eof); //推進堆疊
	struct node *start= CreateNode(nodeQuantity, "START"); //建立node（START）
	struct node *children[2];
	for (int i = 0; i < 2; i++)
		children[i] = pop(); //將堆疊中最後兩個node（obj與END）拿出來
	SetChildren(start, children, 2); //設定children（START）
	push(start); //將start推進去
	fprintf(myStream, "</root>\n");
	printf("Syntax correct!!\n"); //成功reduce到Start->語法正確
	fclose(yyin); //關檔
	printf("Total node = %d\n", nodeQuantity);
	//PrintNode();
	LevelOrder(pop()); //印出parser tree
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
	struct node *opbs = CreateNode(nodeQuantity, "{"); //建立node（{）
	push(opbs); //推進堆疊
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node（{）拿出來
	struct node *openbraces = CreateNode(nodeQuantity, "OPENBRACES"); //建立node（OPENBRACES）
	SetChildren(openbraces, children, 1); //設定OPENBRACES的child
	push(openbraces); //推進堆疊
} pairlist CLOSEBRACES 
{
	struct node *clbs = CreateNode(nodeQuantity, "}");  //建立node（}）
	push(clbs); //推進堆疊
	struct node *children[3];
	children[0] = pop(); //將堆疊裡的最後一個node（}）拿出來
	struct node *closebraces = CreateNode(nodeQuantity, "CLOSEBRACES"); //建立node（CLOSEBRACES）
	SetChildren(closebraces, children, 1); //設定CLOSEBRACES的child
	push(closebraces); //推進堆疊
	struct node *obj = CreateNode(nodeQuantity, "OBJECT"); //建立node（OBJECT）
	for (int i = 0; i < 3; i++){
		children[i] = pop(); //將堆疊裡最後三個node（依序為：CLOSEBRACES、PAIR_LIST、OPENBRACES）拿出來
		//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(obj, children, 3); //設定OBJECT的children
	push(obj); //推進堆疊
}
;

pairlist 
: pair CMM 
{
	struct node *c= CreateNode(nodeQuantity, ","); //建立node（,）
	push(c); //推進堆疊
	struct node *cmm = CreateNode(nodeQuantity, "CMM"); //建立node（CMM）
	struct node *children[1];
	children[0] = pop(); //取出堆疊裡最後一個元素（,）
	SetChildren(cmm, children, 1); //設定CMM的child
	push(cmm); //推進堆疊
} pairlist 
{
	struct node *pairList= CreateNode(nodeQuantity, "PAIR_LIST"); //建立node（PAIR_LIST）
	struct node *children[3];	
	for (int i = 0; i < 3; i++){
		children[i] = pop(); //取出堆疊裡最後三個元素（依序為：CMM、PAIR、PAIR_LIST）
		//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(pairList, children, 3); //設定children
	push(pairList); //推進堆疊
}
| pair
{
	struct node *pairList= CreateNode(nodeQuantity, "PAIR_LIST"); //建立node（PAIR_LIST）
	struct node *children[1];
	children[0] = pop(); //取出堆疊裡最後一個元素（PAIR）
	SetChildren(pairList, children, 1); //設定child
	push(pairList); //推進堆疊
}
;

pair
: key NIL
{ 
	struct node *t = CreateNode(nodeQuantity, "null"); //建立node（null）
	push(t); //推進堆疊
	struct node *pair = CreateNode(nodeQuantity, "PAIR"); //建立node（PAIR）
	struct node *children[2];
	for (int i = 0; i < 2; i++)
		children[i] = pop(); //取出堆疊裡最後兩個元素（依序為：null、KEY）
	SetChildren(pair, children, 2); //設定children
	push(pair); //推進堆疊
	PrintTab(step); //根據第幾層縮排
	fprintf(myStream, "<%s />\n", $1); //null在xml表示成<key />
} 
| key 
{
	PrintTab(step); //根據第幾層縮排
	fprintf(myStream, "<%s>", $1);
} value
{
	struct node *pair = CreateNode(nodeQuantity, "PAIR"); //建立node（PAIR）
	struct node *children[2];
	for (int i = 0; i < 2; i++) {
		children[i] = pop(); //取出堆疊裡最後兩個元素（依序為：VALUE、KEY）
	}
	SetChildren(pair, children, 2); //設定children
	push(pair); //推進堆疊
	fprintf(myStream, "</%s>\n", $1);
} 
| key 
{
	PrintTab(step); //根據第幾層縮排
	fprintf(myStream, "<%s>", $1); 
	arrStack[++arrStackTop] = strdup($1); //將Key的值放到堆疊
} OPSB 
{
	struct node *opsb = CreateNode(nodeQuantity, "["); 
	push(opsb); //推進堆疊
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node（[）拿出來
	struct node *openbraces = CreateNode(nodeQuantity, "OPSB"); //建立node（OPSB）
	SetChildren(openbraces, children, 1); //設定OPENBRACES的child
	push(openbraces); //推進堆疊
} valuelist CLSB
{
	struct node *clsb = CreateNode(nodeQuantity, "]"); //建立node（]）
	push(clsb); //推進堆疊 
	struct node *children[4];
	children[0] = pop(); //將堆疊裡的最後一個node（]）拿出來
	struct node *closebraces = CreateNode(nodeQuantity, "CLSB"); //建立node（CLSB）
	SetChildren(closebraces, children, 1); //設定CLSB的child
	push(closebraces); //推進堆疊
	struct node *pair = CreateNode(nodeQuantity, "PAIR"); //建立node（PAIR）
	for (int i = 0; i < 4; i++)
		children[i] = pop(); //取出堆疊裡最後四個元素（依序為：CLSB、VALUE_LIST、KEY、OPSB）
	SetChildren(pair, children, 4); //設定children
	push(pair); //推進堆疊
	fprintf(myStream, "</%s>\n", arrStack[arrStackTop--]);
} 
;

key
: TEXT COLON 
{
	struct node *t = CreateNode(nodeQuantity, $1); //根據TEXT的內容建立node（$1）
	push(t); //推進堆疊
	struct node *children[2];
	children[0] = pop(); //將堆疊裡的最後一個node（$1）拿出來
	struct node *text = CreateNode(nodeQuantity, "TEXT"); //建立node（TEXT） 
	SetChildren(text, children, 1); //設定child
	push(text); //推進堆疊
	struct node *c = CreateNode(nodeQuantity, ":"); //建立node（:）  
	push(c); //推進堆疊
	children[0] = pop(); //將堆疊裡的最後一個node（:）拿出來
	struct node *colon = CreateNode(nodeQuantity, "COLON"); //建立node（COLON）
	SetChildren(colon, children, 1); //設定child
	push(colon); //推進堆疊
	struct node *key = CreateNode(nodeQuantity, "KEY"); //建立node（KEY）
	for (int i = 0; i < 2; i++)
		children[i] = pop(); //將堆疊裡的最後兩個node拿出來（依序為：COLON、TEXT）
	SetChildren(key, children, 2); //設定children
	push(key); //推進堆疊
}
;

value
:
{
	step++; //多一次縮排
} 
obj 
{
	step--;  //少一次縮排
	PrintTab(step); //根據step決定縮排幾次
	struct node *children[1];
	struct node *value = CreateNode(nodeQuantity, "VALUE"); //建立node（VALUE）
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（OBJECT）
	SetChildren(value, children, 1); //設定child
	push(value); //推進堆疊
}
| TEXT
{
	struct node *t = CreateNode(nodeQuantity, $1); //根據TEXT的內容建立node（$1）
	push(t); //推進堆疊
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（$1）
	struct node *text = CreateNode(nodeQuantity, "TEXT"); //建立node（TEXT）
	SetChildren(text, children, 1); //設定child
	push(text); //推進堆疊
	struct node *value = CreateNode(nodeQuantity, "VALUE"); //建立node（VALUE）
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（TEXT）
	SetChildren(value, children, 1); //設定child
	push(value); //推進堆疊
	fprintf(myStream, "%s", $1);
}
| NIL
{
	struct node *n = CreateNode(nodeQuantity, $1); //根據$1內容建立node（$1）
	push(n); //推進堆疊
	struct node *nil = CreateNode(nodeQuantity, "NIL"); //建立node（NIL）
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（$1）
	SetChildren(nil, children, 1); //設定child
	push(nil); //推進堆疊
	struct node *value = CreateNode(nodeQuantity, "VALUE"); //建立node（VALUE）
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（NIL）
	SetChildren(value, children, 1); //設定child
	push(value); //推進堆疊
	fprintf(myStream, "%s", "null");
}
| NUMBER
{
	struct node *n = CreateNode(nodeQuantity, $1); //根據$1內容建立node（$1）
	push(n); //推進堆疊
	struct node *number = CreateNode(nodeQuantity, "NUMBER"); //建立node（NUMBER）
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（$1）
	SetChildren(number, children, 1); //設定child
	push(number); //推進堆疊
	struct node *value = CreateNode(nodeQuantity, "VALUE"); //建立node（VALUE）
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（NUMBER）
	SetChildren(value, children, 1); //設定child
	push(value); //推進堆疊
	fprintf(myStream, "%s", $1);
}
| BOOLEAN
{
	struct node *b = CreateNode(nodeQuantity, $1); //根據$1內容建立node（$1）
	push(b); //推進堆疊
	struct node *boolean = CreateNode(nodeQuantity, "BOOLEAN"); //建立node（BOOLEAN）
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（$1）
	SetChildren(boolean, children, 1); //設定child
	push(boolean); //推進堆疊
	struct node *value = CreateNode(nodeQuantity, "VALUE"); //建立node（VALUE）
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（BOOLEAN）
	SetChildren(value, children, 1); //設定child
	push(value); //推進堆疊
	fprintf(myStream, "%s", $1);
}
;

valuelist 
: value CMM 
{
	fprintf(myStream, "</%s>\n", arrStack[arrStackTop]); 
	PrintTab(step); //根據step決定縮排幾次
	fprintf(myStream, "<%s>", arrStack[arrStackTop]); 
	struct node *c= CreateNode(nodeQuantity, ","); //建立node（,）
	push(c);  //推進堆疊
	struct node *cmm = CreateNode(nodeQuantity, "CMM"); //建立node（CMM）
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（,）
	SetChildren(cmm, children, 1); //設定child
	push(cmm); //推進堆疊
} valuelist
{
	struct node *valueList= CreateNode(nodeQuantity, "VALUE_LIST"); //建立node（VALUE_LIST）
	struct node *children[3];	
	for (int i = 0; i < 3; i++){
		children[i] = pop(); //將堆疊裡的最後三個node拿出來（依序為：VALUE_LIST、CMM、VALUE）
		//printf("children%d = %d, %s\n", i, children[i]->id, children[i]->name);
	}
	SetChildren(valueList, children, 3); //設定child
	push(valueList); //推進堆疊
}
| value
{
	struct node *valueList= CreateNode(nodeQuantity, "VALUE_LIST"); //建立node（VALUE_LIST）
	struct node *children[1];
	children[0] = pop(); //將堆疊裡的最後一個node拿出來（VALUE）
	SetChildren(valueList, children, 1); //設定child
	push(valueList); //推進堆疊
}
;


%%
//根據times決定輸出幾次tab
void PrintTab(int times){
	for (int i = 0; i < times; i++) {
    		fprintf(myStream, "\t");
	}
}

//以DFS方式print parser tree
void PrintNode(struct node *current){
	if(current == NULL || current->children[0] == NULL) //如果現在的node為NULL，或沒有child就結束
		return;
	printf("%s ->", current->name);
	for (int i = 3; i >= 0; i--)  //因Stack會反過來，這裡print的時候就得反過來print，結果才會是正確的
		if(current->children[i] != NULL) //如果child不為NULL就print
			printf(" %s", current->children[i]->name);
	printf("\n");
	for (int i = 3; i >= 0; i--)
		PrintNode(current->children[i]);
}

//以BFS方式print parser tree
void LevelOrder(struct node *root){
	enqueue(root);                     // 把root作為level-order traversal之起點, 推進queue中
	printf("Parser tree:\n");
	int level[100];
	while (!IsQueueEmpty()){                     // 若queue不是空的, 表示還有node沒有visiting
		struct node *current = dequeue();      // 取出先進入queue的node
		if(current->children[0] != NULL)        
			printf("%s -> ", current->name);   // 進行visiting
		for (int i = 3; i >= 0; i--) {
			if (current->children[i] != NULL){    // 若child有資料, 將其推進queue
				printf("%s ", current->children[i]->name);		
				enqueue(current->children[i]);
			}	
		}
		if(current->children[0] != NULL)        
			printf("\n");
	}
}

//輸出error
void yyerror(char* s){
	printf("%s\nMistake line: %d\n", s, linenum); //print出錯誤內容與哪一行錯誤
	exit(1);
}

int yywrap(){
	return 1;
}

int main(int argc, char* argv[]){
	if ( argc == 2 )
		yyin = fopen(argv[1], "r"); //讀檔

	char* buffer = NULL;
	size_t bufferSize = 0;
	myStream = open_memstream(&buffer, &bufferSize);

	yyparse();
	
	fclose(myStream);
	//將json副檔名改為xml，變成輸出檔案的黨名
	argv[1][strlen(argv[1]) - 4] = 'x';
	argv[1][strlen(argv[1]) - 3] = 'm';
	argv[1][strlen(argv[1]) - 2] = 'l';
	argv[1][strlen(argv[1]) - 1] = '\0';
	out = fopen(argv[1], "w"); //寫檔
	fprintf(out, "%s", buffer);
	fclose(out);
	free(buffer);

	return 0;
}