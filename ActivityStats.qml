import QtQuick
import QtCharts
import QtQuick.Controls

Item {
    width: setWidth
    height: setHeight
    property int setWidth: 100
    property int setHeight: 100

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
                title: "Month Stats (Total Mistakes and Activities)"
                anchors.fill: parent
                legend.alignment: Qt.AlignBottom
                antialiasing: true

                BarSeries
                {
                    id:activityAndMistakesBarSeries
                    axisX: BarCategoryAxis { categories: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31] }
                    axisY: ValueAxis {
                        id: monthYAxis
                        min: 0
                        max: 300  // Initial max value, will be updated dynamically
                    }
                    BarSet
                    {
                        id:monthTotalMistakes
                        label: "Mistakes";
                        color:"red"
                    }
                    BarSet
                    {
                        id:monthTotalMinutes
                        label: "Minutes";
                        color:"blue"
                    }
                }
            }
        }



        onCurrentIndexChanged:
        {
            if(currentIndex===2)
            {
                console.log("month")
                backend.getMonthStats()
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

        function onGetMonthStatsResult(totalMinutesList,totalMistakesList)
        {
            // Update the values
            monthTotalMinutes.values = totalMinutesList
            monthTotalMistakes.values = totalMistakesList
            // Set the min and max for the activity chart for (Total Minutes, mistakes)

            const result = getMinMax(totalMinutesList, totalMistakesList);

            monthYAxis.min = 0 //result.min
            monthYAxis.max = result.max
        }


    }
    Component.onCompleted:
    {
        backend.getWeeklyStats()
    }
}
