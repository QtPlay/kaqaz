import QtQuick 2.2
import Kaqaz 1.0

Rectangle {
    id: main
    width: 48
    height: 70

    property real physicalPlatformScale: kaqaz.density()
    property real fontsScale: 1
    property real platformScale: width/480

    property variant preferenceArray: new Array
    property variant dialogItem
    property variant panelItem

    property variant backHandler

    property real panelHeight: 50*physicalPlatformScale

    property alias touchToBack: back_area.visible
    property alias darkBackground: dark_background.visible

    property alias sidePanel: panel.visible
    property alias panelAnimDuration: panel.anim_time

    property alias stackSwitcher: stack_switcher

    property variant currentFrame: item_a
    property variant nextFrame: item_b

    property bool menuIsVisible: panel.padX != 0

    Component.onCompleted: fontsScale = kaqaz.fontDensity()

    onHeightChanged: {
        main_page.anim = false
        if( dialogItem )
            main_page.y = -main.height - statusBarHeight - navigationBarHeight
    }

    onDialogItemChanged: {
        main_page.anim = true
        if( dialogItem )
        {
            dialogItem.parent = dialog_frame
            dialogItem.anchors.fill = dialog_frame
            dialogItem.visible = true

            main_page.panel_anim = false
            main_page.y = -main.height - statusBarHeight - navigationBarHeight
        }
        else
        {
            main_page.panel_anim = false
            main_page.y = 0
        }
    }

    onPanelItemChanged: {
        main_page.anim = true
        if( panelItem )
        {
            panelItem.parent = panel_frame
            panelItem.anchors.fill = panel_frame
            panelItem.visible = true

            main_page.panel_anim = true
            main_page.y = panelHeight
        }
        else
        {
            main_page.panel_anim = true
            main_page.y = 0
        }
    }

    Connections {
        target: kaqaz
        onBackRequest: main.pressBack()
    }

    Keys.onEscapePressed: pressBack()

    Timer{
        id: panel_visible_timer
        interval: main.panelAnimDuration
        repeat: false
        onTriggered: {
            panelItem = panelItem_tmp
            main.focus = true
        }

        property variant panelItem_tmp
    }

    Image {
        id: background
        x: 0
        y: main_page.y -panelHeight - statusBarHeight
        width: main.width
        height: main.height*2.1 + panelHeight + 2*navigationBarHeight + 2*statusBarHeight
        source: "files/background.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: false
    }

    Item {
        id: panel_frame
        anchors.left: main_page.left
        width: stack_switcher.width - 20*physicalPlatformScale + stack_switcher.platformMargins
        anchors.top: parent.top
        anchors.leftMargin: 10*physicalPlatformScale
        anchors.rightMargin: 10*physicalPlatformScale
        anchors.topMargin: 2*physicalPlatformScale
        height: panelHeight
        z: main_page.y == panelHeight? 10 : 0
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: main_page.bottom
        width: list.width
        x: main_item.parent.x + main_item.width - width
        clip: true
        visible: !portrait

        MirrorItem {
            source: background
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    Rectangle {
        anchors.right: main_page.right
        anchors.bottom: main_page.top
        width: list.width
        height: panel_frame.height
        visible: !portrait
        color: list.color
        clip: true
    }

    Item {
        id: main_page
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        property bool panel_anim: false
        property bool anim: false

        Image{
            id: dark_background
            anchors.fill: main_page
            anchors.topMargin: -statusBarHeight
            anchors.bottomMargin: -navigationBarHeight
            visible: false
            source: "files/menu_background.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: false
//            color: "#000000"
        }

        Behavior on y {
            NumberAnimation { easing.type: main_page.panel_anim? Easing.OutCubic : Easing.InOutQuint; duration: main_page.anim? (main_page.panel_anim? 250 : 1000) : 0 }
        }

        PreferenceDialog {
            id: item_a
            Component.onCompleted: item = main_item
        }

        PreferenceDialog {
            id: item_b
        }

        Item{
            id: main_item
            anchors.fill: parent

            SideBarList{
                id: list
                anchors.right: parent.right
                anchors.rightMargin: portrait? 10*physicalPlatformScale + physicalPlatformScale*40*(1-panel.percent/100) : 0
                width: panel.width
                y: 0
                height: parent.height
                visible: !portrait || panel.visibled || visible_switcher.switcherVariable
                color: portrait? "#00000000" : "#88ffffff"
                fontColor: portrait? "#333333" : "#333333"
                onItemSelected: {
                    panel.itemSelected(id,type)
                    panel.end()
                }
                onCommandSelected: {
                    panel.end()
                }

                Timer{
                    id: visible_switcher
                    repeat: false
                    interval: 2000
                    onTriggered: {
                        if( !switcherVariable ) {
                            switcherVariable = true
                            interval = 100
                            start()
                        } else {
                            switcherVariable = false
                            stop()
                        }
                    }

                    property bool switcherVariable: false
                    Component.onCompleted: visible_switcher.start()
                }
            }

            PaperStackSwitcher{
                id: stack_switcher
                width: portrait? parent.width - platformMargins : parent.width - platformMargins -platformMargins/2 - list.width - 10*physicalPlatformScale
                height: parent.height - platformMargins
                y: platformMargins/2
                anchors.right: portrait? panel.left : list.left
                anchors.rightMargin: portrait? -15 + platformMargins/2 : 0
                clip: !portrait

                DropArea {
                    anchors.fill: parent
                    visible: kaqaz.isDesktop()
                    onDropped: {
                        if( drop.hasUrls ) {
                            var urls = drop.urls
                            for( var i=0; i<urls.length; i++ )
                                stack_switcher.currentFrame.item.currentPaper.addFile(urls[i])
                        }
                        else
                        if( drop.hasText )
                            stack_switcher.currentFrame.item.currentPaper.bodyText += "\n" + drop.text
                    }
                }

                property real platformMargins: kaqaz.mobile? -20 : -6
            }

            SideBar{
                id: panel
                width: portrait? 160*physicalPlatformScale : 200*physicalPlatformScale
                edge: 15
                pinX: parent.width-edge
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: portrait
                onItemSelected: {
                    stack_switcher.show(id, type)
                }

                function refresh(){
                    list.refresh()
                }
            }
        }
    }

    MouseArea{
        id: back_area
        anchors.fill: parent
        visible: false
        onClicked: {
            main.pressBack()
            kaqaz.hideKeyboard()
        }
    }

    Item {
        id: dialog_frame
        anchors.left: main_page.left
        anchors.right: main_page.right
        anchors.top: main_page.top
        anchors.topMargin: main.height+statusBarHeight+navigationBarHeight
        height: main.height
    }

    function refresh(){
        stack_switcher.refresh()
        refreshMenu()
    }

    function refreshMenu(){
        panel.refresh()
    }

    function pushPreference( item ){
        kaqaz.hideKeyboard()
        var current = (preferenceArray.length == 0)? main_item : preferenceArray[preferenceArray.length-1]
        var next = item

        var res = new Array
        for( var i=0; i<preferenceArray.length; i++ )
            res[res.length] = preferenceArray[i]

        res[res.length] = item
        preferenceArray = res

        currentFrame.anim = false
        currentFrame.x = 0
        currentFrame.opacity = 1
        currentFrame.anim = true
        currentFrame.x = -currentFrame.width
        currentFrame.opacity = (preferenceArray.length == 1)? 1 : 0

        nextFrame.anim = false
        nextFrame.x = nextFrame.width
        nextFrame.opacity = (preferenceArray.length == 1)? 1 : 0
        nextFrame.item = next
        nextFrame.anim = true
        nextFrame.x = 0
        nextFrame.opacity = 1

        var tmp = nextFrame
        nextFrame = currentFrame
        currentFrame = tmp

        main_page.focus = true
    }

    function popPreference(){
        kaqaz.hideKeyboard()
        var current = preferenceArray[preferenceArray.length-1]
        var res = new Array
        for( var i=0; i<preferenceArray.length-1; i++ )
            res[res.length] = preferenceArray[i]

        preferenceArray = res

        var next = (preferenceArray.length == 0)? main_item : preferenceArray[preferenceArray.length-1]

        currentFrame.anim = false
        currentFrame.x = 0
        currentFrame.opacity = 1
        currentFrame.anim = true
        currentFrame.x = currentFrame.width
        currentFrame.opacity = (preferenceArray.length == 0)? 1 : 0

        nextFrame.anim = false
        nextFrame.x = -nextFrame.width
        nextFrame.opacity = (preferenceArray.length == 0)? 1 : 0
        nextFrame.item = next
        nextFrame.anim = true
        nextFrame.x = 0
        nextFrame.opacity = 1

        if( current !== main_item )
            kaqaz.deleteItemDelay( current, 250 )

        var tmp = nextFrame
        nextFrame = currentFrame
        currentFrame = tmp

        main.focus = true
    }

    function pressBack(){
        if( backHandler && backHandler.back() )
            return
        if( activeText )
            activeText = 0
        else
        if( rollerVisible )
            hideRollerDialog()
        else
        if( subMessage )
            hideSubMessage()
        else
        if( pointerDialog )
            hidePointDialog()
        else
        if( panel.isVisible() )
            panel.hidePanel()
        else
        if( preferenceArray.length != 0 )
            popPreference()
        else
        if( dialogItem )
            closeDialog()
        else
        if( panelItem )
            closePanel()
        else
        if( stack_switcher.hideCurrentAttachments() )
            return
        else
        if( stack_switcher.type !== PaperManager.Clean ) {
            stack_switcher.show(0, PaperManager.Clean)
        }
        else
        if( !kaqaz.isDesktop() )
            kaqaz.close()
    }

    function showDialog( item ){
        if( dialogItem )
            dialogItem.destroy()

        kaqaz.hideKeyboard()
        dialogItem = item
        main.focus = true
    }

    function closeDialog(){
        if( !dialogItem )
            return

        main_page.anim = true
        kaqaz.hideKeyboard()
        main_page.y = 0
        kaqaz.deleteItemDelay(dialogItem,1000)
        main.focus = true
    }

    function showPanel( item ){
        if( !item && panelItem ) {
            closePanel()
            panelItem.destroy()
            return
        }
        if( panelItem )
            panelItem.destroy()

        item.visible = false
        panel_visible_timer.panelItem_tmp = item
        panel_visible_timer.start()
    }

    function showPanelImedietly( item ){
        if( !item && panelItem ) {
            closePanel()
            panelItem.destroy()
            return
        }
        if( panelItem )
            panelItem.destroy()

        item.visible = false
        panelItem = item
        main.focus = true
    }

    function closePanel(){
        if( !panelItem )
            return

        main_page.anim = true
        back_area.visible = false
        main_page.y = 0
        kaqaz.deleteItemDelay(panelItem,250)
        main.focus = true
    }

    function setCurrentGroup( id, type ){
        stack_switcher.show(id,type)
    }

    function search( txt ){
        stack_switcher.keyword = txt
        stack_switcher.show(0,PaperManager.Search)
    }

    function showSearch(){
        var component = Qt.createComponent("SearchPanel.qml");
        var item = component.createObject(panel_frame);
        item.keywordChanged.connect(main.search)
        showPanel(item)
    }

    function clean(){
        stack_switcher.clean()
    }

    function showPrefrences(){
        var component = Qt.createComponent("Preference.qml");
        var item = component.createObject(main);
        main.pushPreference(item)
    }

    function showHistory(){
        var component = Qt.createComponent("History.qml");
        var item = component.createObject(main);
        main.pushPreference(item)
    }

    function showListView(){
        var list = stack_switcher.currentFrame.item.papers
        if( !list || list.length == 0 ) {
            showTooltip(qsTr("List is empty"))
            return
        }

        var component = Qt.createComponent("PaperList.qml");
        var item = component.createObject(main);
        item.list = list
        item.positionViewAtIndex(main.stackSwitcher.currentFrame.item.currentIndex)
        main.pushPreference(item)
    }

    function showMenu(){
        panel.showPanel()
    }

    function incomingShare( title, message ) {
        stack_switcher.incomingShare(title,message)
    }

    function incomingImage( path ) {
        stack_switcher.incomingImage(path)
    }

    function initPapers() {
        stack_switcher.init()
    }
}