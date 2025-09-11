import QtQuick
import QtQuick.Controls
import "CustomComponents"
import QtCharts 6.0

Page
{
    width:parent.width
    height: parent.height
    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background
        //![1]
        ChartView {
               anchors.fill: parent
               antialiasing: true

               // Time Spent axis (on the left)
               ValueAxis {
                   id: timeAxis
                   min: 0
                   max: 12  // Max value based on time spent data
                   tickCount: 6
                   titleText: "Time Spent (hrs)"
               }

               // Mistakes Made axis (on the right)
               ValueAxis {
                   id: mistakesAxis
                   min: 0
                   max: 200  // Max value based on mistakes data
                   tickCount: 5
                   titleText: "Mistakes Made"
                   position: ValueAxis.Right
               }

               // Horizontal Bar Chart
               HorizontalBarSeries {
                   axisX: BarCategoryAxis { categories: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] }

                   // Time Spent BarSet
                   BarSet {
                       label: "Time Spent"
                       values: [10, 2, 1, 4, 0.2, 1, 2]
                   }

                   // Mistakes Made BarSet
                   BarSet {
                       label: "Mistakes Made"
                       values: [10, 50, 84, 41, 10, 0, 150]
                   }

                   // Link Mistakes Made series to the right axis
                   axisY: mistakesAxis
               }

               // Link the time spent series to the left axis
               axisY: timeAxis
           }

        // Text
        // {
        //     text:"soon"
        //     color:appColors.c_fontcolor
        //     font.pixelSize: appFontSizes.f_title
        //     anchors.centerIn: parent
        // }
    }
}
