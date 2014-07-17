import QtQuick 2.2
import Kaqaz 1.0

Item {
    id: switcher
    width: 100
    height: 62

    property bool anim: false

    property int type: PaperManager.Clean
    property int current
    property string keyword

    property variant currentFrame: item_a
    property variant nextFrame: item_b

    property real interval: 400
    property real outScale: 1

    Timer {
        id: item_destroyer_timer
        interval: switcher.interval
        repeat: false
        onTriggered: {
            nextFrame.visible = false
            if( nextFrame.item ) nextFrame.item.destroy()
        }
    }

    Timer {
        id: switcher_timer
        interval: panelAnimDuration
        repeat: false
        onTriggered: switchItems()
    }

    Timer {
        id: switcher_s2_timer
        interval: 50
        repeat: false
        onTriggered: switchSection2()
    }

    Timer {
        id: paste_timer
        interval: 500
        repeat: false
        onTriggered: {
            if( !currentFrame.item || !currentFrame.item.currentPaper ) {
                restart()
                return
            }
            if( switcher_timer.running || switcher_s2_timer.running || item_destroyer_timer.running ) {
                restart()
                return
            }

            currentFrame.item.currentPaper.text = title
            currentFrame.item.currentPaper.bodyText = message
        }

        property string title
        property string message
    }

    Timer {
        id: img_timer
        interval: switcher_s2_timer.interval + switcher_timer.interval + 1000
        repeat: false
        onTriggered: {
            currentFrame.item.currentPaper.addFile(path)
            currentFrame.item.currentPaper.showAttachments()
            kaqaz.removeFile(path)
        }

        property string path
    }

    PaperStackSwitcherItem {
        id: item_a

        Behavior on x {
            NumberAnimation { easing.type: Easing.InOutQuint; duration: switcher.anim? switcher.interval : 0 }
        }
        Behavior on scale {
            NumberAnimation { easing.type: Easing.InOutQuint; duration: switcher.anim? switcher.interval : 0 }
        }
    }

    PaperStackSwitcherItem {
        id: item_b
        visible: false
        x: -switcher.width

        Behavior on x {
            NumberAnimation { easing.type: Easing.InOutQuint; duration: switcher.anim? switcher.interval : 0 }
        }
        Behavior on scale {
            NumberAnimation { easing.type: Easing.InOutQuint; duration: switcher.anim? switcher.interval : 0 }
        }
    }

    onCurrentChanged: {
        switcher_timer.restart()
    }
    onKeywordChanged: {
        switcher_timer.restart()
    }

    Component {
        id: paper_manager_component
        PaperManagerItem{}
    }

    function hideCurrentAttachments(){
        if( !currentFrame.item )
            return false
        return currentFrame.item.hideCurrentAttachments()
    }

    function refresh(){
        switchItems()
    }

    function switchItems(){
        if( nextFrame.item )
            nextFrame.item.destroy()

        nextFrame.item = createItem()
        nextFrame.item.type = type
        nextFrame.item.keyword = keyword
        nextFrame.item.root = current
        nextFrame.visible = true

        switcher_s2_timer.start()
    }

    function switchSection2(){
        switcher.anim = false
        nextFrame.x = switcher.width
        nextFrame.scale = outScale
        currentFrame.x = 0
        currentFrame.scale = 1

        switcher.anim = true
        nextFrame.x = 0
        nextFrame.scale = 1
        currentFrame.x = -switcher.width
        currentFrame.scale = outScale

        var tmp = nextFrame
        nextFrame = currentFrame
        currentFrame = tmp

        item_destroyer_timer.start()
    }

    function createItem(){
        var item = paper_manager_component.createObject(switcher);
        return item
    }

    function init(){
        switcher_timer.start()
    }

    function clean(){
        type = PaperManager.Clean
        current = 0
        switcher_timer.restart()
    }

    function show( rid, rtype ){
        type = rtype
        current = rid
        switcher_timer.restart()
    }

    function incomingShare( title, message ) {
        clean()
        paste_timer.title = title
        paste_timer.message = message
        paste_timer.restart()
    }

    function incomingImage( path ) {
        clean()
        img_timer.path = path
        img_timer.restart()
    }
}