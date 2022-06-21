# Compiler Program Final
報告題目為將JSON轉換為XML

## 小組成員
108590005 何秉育 : Lexical analysis & Code generation  
108590016 陳琴連 : Syntax analysis & Code generation

## 執行
環境需要安裝`flex`及`bison`  
使用`make`指令將程式進行編譯  
輸入檔案進行文法判斷：`.\converter .\samples\sample1.json`  
hint:
- 在samples資料夾中有5個範例檔案(3 & 4為錯誤範例)  
- 成功轉換會在json檔案旁 新增/寫入 xml檔案，失敗則不會更動檔案

## JSON格式簡介
JSON 是一種輕量級資料交換格式，由屬性和值所組成，優點是易於閱讀和處理。  
目前 JSON 使用在 JavaScript、Java、Node.js、C#應用的情況比較多。 

JSON 的基本資料類型有
- 數值
- 字串
- 布林值
- 陣列
- 物件
- 空值

## 限制
因我們設定在JSON中的array轉換為XML時要避免資料失真(程式在XML檔案中自動加入其他元素)，處理方式為:
- 各value獨立在XML中為分別的元素
- 轉換為XML後的標籤為該array的key

造成若有array內的value直接為array會無法處理

## 成果
以下json格式為輸入，xml格式為輸出
```json
{
  "menu": {
    "id": "file",
    "value": "File",
    "popup": {
      "menuitem": [
        {
          "test": "\"Test\"",
          "value": "New",
          "onclick": "CreateNewDoc()"
        },
        {
          "number": 345,
          "value": "Open",
          "onclick": "OpenDoc()"
        },
        {
          "bool": false,
          "value": "Close",
          "onclick": "CloseDoc()"
        }
      ]
    },
    "neg_number": -123,
    "float_number": 345.123,
    "exp_number_pos": 7.823E5,
    "exp_number_neg": 1.2e-4,
    "null_object": null
  }
}
```
```xml
<root>
	<menu>
		<id>file</id>
		<value>File</value>
		<popup>
			<menuitem>
				<test>\"Test\"</test>
				<value>New</value>
				<onclick>CreateNewDoc()</onclick>
			</menuitem>
			<menuitem>
				<number>345</number>
				<value>Open</value>
				<onclick>OpenDoc()</onclick>
			</menuitem>
			<menuitem>
				<bool>false</bool>
				<value>Close</value>
				<onclick>CloseDoc()</onclick>
			</menuitem>
		</popup>
		<neg_number>-123</neg_number>
		<float_number>345.123</float_number>
		<exp_number_pos>7.823E5</exp_number_pos>
		<exp_number_neg>1.2e-4</exp_number_neg>
		<null_object />
	</menu>
</root>

```
若語法正確則以DFS、BFS兩種方式print出parser tree
```
==================DFS==================
START -> OBJECT EOF
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> menu
COLON -> :
VALUE -> OBJECT
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> id
COLON -> :
VALUE -> TEXT
TEXT -> file
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> value
COLON -> :
VALUE -> TEXT
TEXT -> File
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> popup
COLON -> :
VALUE -> OBJECT
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR
PAIR -> KEY OPSB VALUE_LIST CLSB
KEY -> TEXT COLON
TEXT -> menuitem
COLON -> :
OPSB -> [
VALUE_LIST -> VALUE CMM VALUE_LIST
VALUE -> OBJECT
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> test
COLON -> :
VALUE -> TEXT
TEXT -> \"Test\"
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> value
COLON -> :
VALUE -> TEXT
TEXT -> New
CMM -> ,
PAIR_LIST -> PAIR
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> onclick
COLON -> :
VALUE -> TEXT
TEXT -> CreateNewDoc()
CLOSEBRACES -> }
CMM -> ,
VALUE_LIST -> VALUE CMM VALUE_LIST
VALUE -> OBJECT
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> number
COLON -> :
VALUE -> NUMBER
NUMBER -> 345
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> value
COLON -> :
VALUE -> TEXT
TEXT -> Open
CMM -> ,
PAIR_LIST -> PAIR
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> onclick
COLON -> :
VALUE -> TEXT
TEXT -> OpenDoc()
CLOSEBRACES -> }
CMM -> ,
VALUE_LIST -> VALUE
VALUE -> OBJECT
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES
OPENBRACES -> {
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> bool
COLON -> :
VALUE -> BOOLEAN
BOOLEAN -> false
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> value
COLON -> :
VALUE -> TEXT
TEXT -> Close
CMM -> ,
PAIR_LIST -> PAIR
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> onclick
COLON -> :
VALUE -> TEXT
TEXT -> CloseDoc()
CLOSEBRACES -> }
CLSB -> ]
CLOSEBRACES -> }
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> neg_number
COLON -> :
VALUE -> NUMBER
NUMBER -> -123
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> float_number
COLON -> :
VALUE -> NUMBER
NUMBER -> 345.123
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> exp_number_pos
COLON -> :
VALUE -> NUMBER
NUMBER -> 7.823E5
CMM -> ,
PAIR_LIST -> PAIR CMM PAIR_LIST
PAIR -> KEY VALUE
KEY -> TEXT COLON
TEXT -> exp_number_neg
COLON -> :
VALUE -> NUMBER
NUMBER -> 1.2e-4
CMM -> ,
PAIR_LIST -> PAIR
PAIR -> KEY null
KEY -> TEXT COLON
TEXT -> null_object
COLON -> :
CLOSEBRACES -> }
CLOSEBRACES -> }
==================BFS==================
Parser tree:
START -> OBJECT EOF 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
OPENBRACES -> { 
PAIR_LIST -> PAIR 
CLOSEBRACES -> } 
PAIR -> KEY VALUE 
KEY -> TEXT COLON 
VALUE -> OBJECT 
TEXT -> menu 
COLON -> : 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
OPENBRACES -> { 
PAIR_LIST -> PAIR CMM PAIR_LIST 
CLOSEBRACES -> } 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
TEXT -> id 
COLON -> : 
TEXT -> file 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
TEXT -> value 
COLON -> : 
TEXT -> File 
KEY -> TEXT COLON 
VALUE -> OBJECT 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
TEXT -> popup 
COLON -> : 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
KEY -> TEXT COLON 
VALUE -> NUMBER 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
OPENBRACES -> { 
PAIR_LIST -> PAIR 
CLOSEBRACES -> } 
TEXT -> neg_number 
COLON -> : 
NUMBER -> -123 
KEY -> TEXT COLON 
VALUE -> NUMBER 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
PAIR -> KEY OPSB VALUE_LIST CLSB 
TEXT -> float_number 
COLON -> : 
NUMBER -> 345.123 
KEY -> TEXT COLON 
VALUE -> NUMBER 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR 
KEY -> TEXT COLON 
OPSB -> [ 
VALUE_LIST -> VALUE CMM VALUE_LIST 
CLSB -> ] 
TEXT -> exp_number_pos 
COLON -> : 
NUMBER -> 7.823E5 
KEY -> TEXT COLON 
VALUE -> NUMBER 
PAIR -> KEY null 
TEXT -> menuitem 
COLON -> : 
VALUE -> OBJECT 
CMM -> , 
VALUE_LIST -> VALUE CMM VALUE_LIST 
TEXT -> exp_number_neg 
COLON -> : 
NUMBER -> 1.2e-4 
KEY -> TEXT COLON 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
VALUE -> OBJECT 
CMM -> , 
VALUE_LIST -> VALUE 
TEXT -> null_object 
COLON -> : 
OPENBRACES -> { 
PAIR_LIST -> PAIR CMM PAIR_LIST 
CLOSEBRACES -> } 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
VALUE -> OBJECT 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
OPENBRACES -> { 
PAIR_LIST -> PAIR CMM PAIR_LIST 
CLOSEBRACES -> } 
OBJECT -> OPENBRACES PAIR_LIST CLOSEBRACES 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
OPENBRACES -> { 
PAIR_LIST -> PAIR CMM PAIR_LIST 
CLOSEBRACES -> } 
TEXT -> test 
COLON -> : 
TEXT -> \"Test\" 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
KEY -> TEXT COLON 
VALUE -> NUMBER 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR CMM PAIR_LIST 
TEXT -> value 
COLON -> : 
TEXT -> New 
KEY -> TEXT COLON 
VALUE -> TEXT 
TEXT -> number 
COLON -> : 
NUMBER -> 345 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
KEY -> TEXT COLON 
VALUE -> BOOLEAN 
PAIR -> KEY VALUE 
CMM -> , 
PAIR_LIST -> PAIR 
TEXT -> onclick 
COLON -> : 
TEXT -> CreateNewDoc() 
TEXT -> value 
COLON -> : 
TEXT -> Open 
KEY -> TEXT COLON 
VALUE -> TEXT 
TEXT -> bool 
COLON -> : 
BOOLEAN -> false 
KEY -> TEXT COLON 
VALUE -> TEXT 
PAIR -> KEY VALUE 
TEXT -> onclick 
COLON -> : 
TEXT -> OpenDoc() 
TEXT -> value 
COLON -> : 
TEXT -> Close 
KEY -> TEXT COLON 
VALUE -> TEXT 
TEXT -> onclick 
COLON -> : 
TEXT -> CloseDoc() 
```