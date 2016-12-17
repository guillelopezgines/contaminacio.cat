class @Graph extends React.Component
  @propTypes =
    data: React.PropTypes.array

  componentDidMount: ->
    data = this.props.data
    
    markings = []
    markings.push({ color: '#2E4053', lineWidth: 8, yaxis: { from: this.props.last_week_average, to: this.props.last_week_average }}) if this.props.last_week_average
    markings.push({ color: '#ff5252', lineWidth: 10, yaxis: { from: this.props.year_limit_spain, to: this.props.year_limit_spain }})
    markings.push({ color: '#ff5252', lineWidth: 5, yaxis: { from: this.props.year_limit_oms, to: this.props.year_limit_oms }})

    options =
      series:
        lines:
          show: true
          fill: false
          steps: false
          lineWidth: 3
        points:
          show: false
          fill: true
          radius: 3
      shadowSize: 0
      colors: ['#333', '#FE9000', '#FFDD4A', '#5ADBFF', '#3C6997', '#094074']
      grid:
        color: 'rgba(151, 151, 151, 0.6)'
        clickable: false
        hoverable: true
        margin: 10
        labelMargin: 10
        axisMargin: 0
        borderWidth: { top: 1, bottom: 1, left: 0, right: 0 }
        markings: markings
      legend:
        position: "nw"
        noColumns: 7

      xaxis:
        mode: "time"
        font:
          size: 10
          weight: "bold"
          color: 'rgba(151, 151, 151, 0.6)'
      yaxis:
        tickSize: 10
        min: 0
        tickFormatter: (val) -> val
        font:
          size: 9
          weight: "bold"
          color: "black"

    $(document).ready ->
      $(window)
        .on 'resize', ->
          width = $(window).width()
          $('.graph').css('height', width * .6)
          options.series.lines.lineWidth = if width > 600 then 3 else 1
          $.plot($('.graph'), data, options)
        .trigger 'resize'

      $("<div id='tooltip'></div>").css(
        position: "absolute"
        display: "none"
        border: "1px solid #fdd"
        padding: "2px"
        "background-color": "#fee"
        opacity: 0.80
      ).appendTo("body")

      add_zero = (i) ->
        i = "0" + i if (i < 10)
        return i

      $(".graph").bind "plothover", (event, pos, item) ->
        if (item)
          x = item.datapoint[0].toFixed(2)
          y = item.datapoint[1].toFixed(2)
          amount = item.datapoint[1]
          date = new Date(item.datapoint[0] - 1 * 60 * 60 * 1000);
          content = amount + " " + window.unit + " at " + date
          content = label + ":<br>" + content if label = item.series.label

          $("#tooltip")
            .html(content)
            .css({top: item.pageY + 5, left: if item.pageX < $(".graph").width() * .5 then (item.pageX + 5) else (item.pageX - $("#tooltip").outerWidth() - 10)})
            .fadeIn(200)
        else
          $("#tooltip").hide()
          

  componentWillUnmount: ->
    $(window)
      .off 'resize'

  render: ->
    return `<div className="graph"></div>`
