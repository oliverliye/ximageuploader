ximageloader 简介
--------------------
* 基于html javascript ajax 的图片上传组件，支持拖拽、粘贴

使用方法：
------------

ximageloader是用coffeescript写的，如果自己编译需安装nodejs和coffeescript;也可以直接引用编译好的ximageloader.js。
```html
<!-- HTML5 -->
<script src="ximageloader.js"></script>

<!-- For HTML4/IE -->
<script type="text/javascript" src="ximageloader.js"></script>
```
需要有一个div来生成上传组件, 必须有contenteditable属性
```html
<div upload-area style="#{imageAreaCss}" contenteditable="true"></div>
```


