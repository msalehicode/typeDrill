import QtQuick
import QtCharts
import QtQuick.Controls

Item {
    width: setWidth
    height: setHeight
    property int setWidth: 100
    property int setHeight: 100

    property var weekListTitle: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    SwipeView {
        id: view

        currentIndex: 0
        anchors.fill: parent

        Item {
            id: firstPage
            ChartView {
                title: "Week Stats (Total Activity)"
                anchors.fill: parent
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id:activityBarSeries

                    axisX: BarCategoryAxis { categories: weekListTitle }
                    axisY: ValueAxis {
                        id: activityYAxis
                        min: 0
                        max: 300  // Initial max value, will be updated dynamically
                    }
                    BarSet
                    {
                        id:weekTotalMinutes
                        label: "Minutes";
                        color:"blue"
                    }
                }
            }
        }

        Item {
            id: secondPage
            ChartView
            {
                title: "Week Stats (Total Mistakes)"
                anchors.fill: parent
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries {
                    id:mistakesBarSeries
                    axisX: BarCategoryAxis { categories: weekListTitle }
                    axisY: ValueAxis {
                        id: mistakesYAxis
                        min: 0
                        max: 300  // Initial max value, will be updated dynamically
                    }
                    BarSet
                    {
                        id:weekTotalMistakes
                        label: "Mistakes";
                        color:"red"
                    }
                }
            }
        }

    }

    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Connections
    {
        target:backend
        function onGetWeeklyStatsResult(totalMinutesList,totalMistakesList)
        {
            // console.log("Received totalMistakesList:", totalMistakesList)
            // console.log("Received totalMinutesList:", totalMinutesList)

            // Update the values
            weekTotalMinutes.values = totalMinutesList
            weekTotalMistakes.values = totalMistakesList


            // Set the min and max for the activity chart (Total Minutes)
            activityYAxis.min = Math.min(...totalMinutesList);
            activityYAxis.max = Math.max(...totalMinutesList);

            // Set the min and max for the mistakes chart (Total Mistakes)
            mistakesYAxis.min = Math.min(...totalMistakesList);
            mistakesYAxis.max = Math.max(...totalMistakesList);
        }
    }
    Component.onCompleted:
    {
        backend.getWeeklyStats()
    }
}
