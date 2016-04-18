### 
ximageuploadr is image upload interface
support drag paste

https://github.com/oliverliye/ximageuploader
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
    div = document.createElement 'div'
    div.setAttribute 'contenteditable', true
    div.setAttribute 'tabindex', -1
    div.style.width = "1px"
    div.style.height = "1px"
    div.style.position = "fixed"
    div.style.left = "-100px"
    div.overflow = 'hidden'
    div


class Element 
    constructor: (element) -> @dom = element

    attr: (name, value) ->
        unless value
            return @dom.getAttribute name
        else
            @dom.setAttribute name, value
    append: (dom)-> @dom.appendChild dom


    empty: ()-> @dom.innerHTML = ""
    isDiv: () -> @dom.nodeName is 'DIV' || @dom.nodeName is 'div'
    isImg: () -> @dom.nodeName is 'IMG' || @dom.nodeName is 'img'


class XImageUploader
    constructor: (element, config) ->
        @el = new Element element
        return null unless @el.isDiv()
        @paste = new Element createHiddenEditable()
        @config = extend defaults, config

        @el.append @paste.dom
        @el.dom.onclick = => @paste.dom.focus()

        @el.dom.ondrop = (e)=>
            e.stopPropagation()
            e.preventDefault()
            onDrop @, e

        @el.dom.ondragenter = @el.dom.ondragover = (e)->
            e.stopPropagation()
            e.preventDefault()

        @el.dom.onblur = ()=> @el.empty()

        @paste.dom.onpaste = (e)=> onPaste @, e

    isAllowed: (type) ->
        (return true if t.indexOf(type) >= 0) for t in @config.types
        return false

onDrop = (loader, e)->
    maxFile = loader.config.maxFile
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
        	loader.el.empty()
        , 1

loadImageFromClip = (loader, src)->
    if src.match /^webkit\-fake\-url\:\/\//
        console.log "error"
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

