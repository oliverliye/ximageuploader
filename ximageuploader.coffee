### 
ximageuploadr is image upload interface
support drag paste

https://github.com/oliverliye/ximageuploader
http://www.oliverliye.com/XImageUploader
###

defaults = 
    maxFile: 1
    types: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif']
    onFileUploaded: ()->
    onError: ()->

extend = (d, s)-> 
    d[k] = v for k, v of s
    d

createHiddenEditable = ->
    div = new Element document.createElement 'div'
    div.attr 'contenteditable', true
    div.attr 'tabindex', -1
    div.css "width", "1px"
    div.css "height", "1px"
    div.css "position", "fixed"
    div.css "left", "-9999px"
    div.css "overflow", "hidden"
    div

createFormUpload = (input, url, loader) ->
    form = new Element document.createElement 'form'
    form.attr 'method', 'POST'
    form.attr 'action', url
    form.attr 'enctype', 'multipart/form-data'
    form.attr 'target', loader.uid
    file = new Element input.clone()
    file.dom.onchange =  change = ->
        iframe = createUploadIFrame loader.uid
        form.append iframe
        iframe.dom.onload = ->
            loader.config.onFileUploaded iframe.dom.contentWindow.document.body.innerHTML
            iframe.dom.onload = null
            form.remove iframe
            form.remove file
            file = new Element input.clone()
            file.dom.onchange = change
            form.append file
        form.dom.submit()
    form.append file
    form

createUploadIFrame = (target)->
    iframe = new Element document.createElement 'iframe'
    iframe.attr "name", target
    iframe.css "display", "none"
    iframe


class Element 
    constructor: (element) -> @dom = element

    attr: (name, value) ->
        unless value
            return @dom.getAttribute name
        else
            @dom.setAttribute name, value
    css: (name, value) -> @dom.style[name] = value

    append: (node)-> @dom.appendChild node.dom
    remove: (node)-> @dom.removeChild node.dom
    clone: -> @dom.cloneNode()
    focus: -> @dom.focus()
    empty: ()-> @dom.innerHTML = ""
    isDiv: () -> @dom.nodeName is 'DIV' or @dom.nodeName is 'div'
    isImg: () -> @dom.nodeName is 'IMG' or @dom.nodeName is 'img'
    isFileInput: () -> @dom.nodeName is 'INPUT' or @dom.nodeName is 'input' and @dom.getAttribute('type') is 'file'

class XImageUploader
    constructor: (element, config) ->
        @uid = new Date().getTime()
        @el = new Element element
        return null unless @el.isDiv()

        @paste = createHiddenEditable()
        @config = extend defaults, config

        @el.append @paste
        @el.dom.onclick = => @paste.focus()

        @el.dom.ondrop = (e)=>
            if event = e
                event.stopPropagation()
                event.preventDefault()
            else if event = window.event
                event.returnValue = false
                event.cancelBubble = true
            onDrop @, event 

        @el.dom.ondragenter = @el.dom.ondragover = (e)->
            if event = e
                event.stopPropagation()
                event.preventDefault()
            else if event = window.event
                event.returnValue = false
                event.cancelBubble = true

        @paste.dom.onpaste = (e)=> onPaste @, e

        for child in @el.dom.childNodes
            input = new Element child
            if input.isFileInput()
                @file = createFormUpload input, config.url, @
                @el.append @file
                @el.remove input
                break  

    isAllowed: (type) ->
        (return true if t.indexOf(type) >= 0) for t in @config.types
        return false

onDrop = (loader, e)->
    maxFile = loader.config.maxFile
    return unless files = e.dataTransfer.files
    uploadFile loader, file for file in e.dataTransfer.files
    return

onPaste = (loader, e)->
    if e.clipboardData
        items = e.clipboardData.items

        # chrome
        if items
            for item, i in items
                continue unless loader.isAllowed item.type
                uploadFile loader, item.getAsFile()
            return
        # firefox
        else
            setTimeout =>
                for child in loader.paste.dom.childNodes
                    child = new Element child
                    continue unless child.isImg()
                    loadImageFromClip loader, child.attr('src')
                loader.paste.empty()
                return
            , 1
    
    if window.clipboardData
    	for file in window.clipboardData.files
            loadImageFromClip loader, URL.createObjectURL(file)
        setTimeout => 
        	loader.paste.empty()
        , 1

loadImageFromClip = (loader, src)->
    return loader.config.onError() if src.match /^webkit\-fake\-url\:\/\//

    img = new Image()
    img.crossOrigin = "anonymous"
    img.onload = =>
        canvas = document.createElement 'canvas'
        canvas.width = img.width
        canvas.height = img.height
        ctx = canvas.getContext '2d'
        ctx.drawImage img, 0, 0, canvas.width, canvas.height
        dataURL = canvas.toDataURL 'image/png'
        uploadFile loader, dataURL
        console.log dataURL

    img.onerror = => loader.config.onError()
    img.src = src

uploadFile = (loader, file)->
    formData = new FormData()
    xhr = new XMLHttpRequest()

    if typeof file is 'object'
    	formData.append 'file', file, file.name
    else 
   		formData.append 'file', file

    xhr.open 'POST', loader.config.url

    xhr.onload = () ->
        if xhr.status is 200 or xhr.status is 201
            loader.config.onFileUploaded xhr.responseText
        else
            loader.config.onError()

    xhr.send formData

window.XImageUploader = XImageUploader

