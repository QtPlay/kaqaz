/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Item {
    id: group_chooser_back
    width: kaqaz.mobile? 75*physicalPlatformScale : 100*physicalPlatformScale
    height: 30*physicalPlatformScale

    property real radius: 5*physicalPlatformScale
    property color color: "#aaaaaa"

    property int group
    property bool press: false

    onGroupChanged: {
        txt.text = database.groupName(group)
        color = database.groupColor(group)
    }

    Rectangle{
        anchors.fill: parent
        anchors.bottomMargin: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Rectangle{
        anchors.fill: parent
        radius: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Text{
        id: txt
        x: (width>group_chooser_back.width)? 0 : group_chooser_back.width/2 - width/2
        y: group_chooser_back.height/2 - height/2
        font.bold: kaqaz.tablet
        font.pixelSize: kaqaz.touchDevice? (kaqaz.mobile? 8*fontsScale : 9*fontsScale) : 10*fontsScale
        font.family: globalFontFamily
        color: "#ffffff"
        text: qsTr("No Label")
    }

}
