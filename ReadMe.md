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
- 在samples資料夾中有4個範例檔案(3 & 4為錯誤範例)  
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