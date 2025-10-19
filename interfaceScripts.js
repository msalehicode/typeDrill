function blurRandomChars(input, fractionStr) {
    if (!input || input.length === 0) return ""

    // Parse the fraction like "1/2" → numerator: 1, denominator: 2
    var parts = fractionStr.split("/")
    var numerator = parseInt(parts[0])
    var denominator = parseInt(parts[1])

    if (isNaN(numerator) || isNaN(denominator) || denominator === 0) {
        console.warn("Invalid fraction:", fractionStr)
        return input
    }

    // Calculate how many characters to blur
    var blurCount = Math.ceil(input.length * (numerator / denominator))

    var chars = input.split("")
    var indices = []

    while (indices.length < blurCount && indices.length < input.length) {
        var randIndex = Math.floor(Math.random() * input.length)
        if (!indices.includes(randIndex)) {
            indices.push(randIndex)
        }
    }

    for (var i = 0; i < indices.length; i++) {
        chars[indices[i]] = "*"
    }

    return chars.join("")
}



function getValueByKey(dataList, firstKey)
{
    if (!dataList || dataList.length === 0)
        return "";

    for (var i = 0; i < dataList.length; ++i)
    {
        var row = dataList[i];
        if (firstKey in row)
            return row[firstKey];
    }
    return "";
}



function modifyWordValue(data,key,value)
{
    for (var i = 0; i < data.length; ++i)
    {
        var row = data[i];
        if (key in row)
            row[key]=value;
    }
}
