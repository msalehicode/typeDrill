import QtQuick
import QtCharts
import QtQuick.Controls

Item {
    anchors.fill: parent
    property int setWidth: 100
    property int setHeight: 100
    property var vartotalMinutesList: [10, 22, 33, 42, 33]

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

                    axisX: BarCategoryAxis { categories: appGlobalValues.weekDays }
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
                    axisX: BarCategoryAxis { categories: appGlobalValues.weekDays }
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


        Item {
            id: thirdPage

            ChartView
            {
                width: parent.width
                height: parent.height
                title: "Month Stats"

                // Define X and Y axes
                ValuesAxis {
                    id: monthAxisX
                    min: 1
                    max: 31
                    tickInterval: 2
                    // tickCount: totalMinutesList.length
                }

                ValuesAxis {
                    id: monthAxisY
                    min: 0
                    max: 10  // Adjust this value according to your data range
                }

                // LineSeries for the data
                LineSeries {
                    id:minutesSeries
                    name: "Total Minutes"
                    axisX: monthAxisX
                    axisY: monthAxisY
                    color:"blue"
                }
                LineSeries {
                    id:mistakesSeries
                    name: "Total Mistakes"
                    axisX: monthAxisX
                    axisY: monthAxisY
                    color:"red"
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

        onCurrentIndexChanged:
        {
            if(currentIndex===2)
                backend.getMonthStats()
        }
    }


    function getMinMax(list1, list2)
    {
        // Merge both lists into one
        const mergedList = [...list1, ...list2];

        // Find the minimum and maximum values in the merged list
        const min = Math.min(...mergedList);
        const max = Math.max(...mergedList);

        return { min, max };
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
            activityYAxis.min = 0 //Math.min(...totalMinutesList);
            activityYAxis.max = Math.max(...totalMinutesList);

            // Set the min and max for the mistakes chart (Total Mistakes)
            mistakesYAxis.min = 0 //Math.min(...totalMistakesList);
            mistakesYAxis.max = Math.max(...totalMistakesList);
        }


        function onGetMonthStatsResult(totalMinutesList, totalMistakesList)
        {
            minutesSeries.clear()
            mistakesSeries.clear()

            monthAxisY.min=0
            monthAxisY.max= getMinMax(totalMinutesList,totalMistakesList).max

            for (var i = 0; i < totalMinutesList.length; i++)
                minutesSeries.append(i, totalMinutesList[i]);


            for (var i = 0; i < totalMistakesList.length; i++)
                mistakesSeries.append(i, totalMistakesList[i]);
        }


    }
    Component.onCompleted:
    {
        backend.getWeeklyStats()
    }
}
