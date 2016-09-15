class @Graph extends React.Component
  @propTypes =
    data: React.PropTypes.array

  componentDidMount: ->
    data = [this.props.data]
  
    yaxis: {
      minTickSize: 1,
      tickDecimals: 0
    },
    xaxis: {
      mode: "time",
      minTickSize: [1, "month"]
    }

    options =
      series:
        lines:
          show: true
          fill: false
          steps: false
          lineWidth: 3
        points:
          show: true
          fill: true
          radius: 3
      shadowSize: 0
      colors: ['#333']
      grid:
        color: 'rgba(151, 151, 151, 0.6)'
        clickable: false
        hoverable: true
        margin: 10
        labelMargin: 10
        axisMargin: 0
        borderWidth: { top: 1, bottom: 1, left: 0, right: 0 }
        markings: [
          { color: '#ff5252', lineWidth: 10, yaxis: { from: this.props.year_limit_spain, to: this.props.year_limit_spain } }
          { color: '#ff5252', lineWidth: 5, yaxis: { from: this.props.year_limit_oms, to: this.props.year_limit_oms } }
        ]

      xaxis:
        mode: "time"
        minTickSize: [1, "day"]
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
          $('.graph').css('height', $(window).width() * .6)
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

      $(".graph").bind "plothover", (event, pos, item) ->
        if (item)
          x = item.datapoint[0].toFixed(2)
          y = item.datapoint[1].toFixed(2)
          amount = item.datapoint[1]
          date = new Date(item.datapoint[0]);

          $("#tooltip").html(amount + " " + window.unit + "<br>" + date.getDay() + "/" + date.getMonth() + "/" + date.getFullYear())
            .css({top: item.pageY+5, left: item.pageX+5})
            .fadeIn(200)
        else
          $("#tooltip").hide()
          

  componentWillUnmount: ->
    $(window)
      .off 'resize'

  render: ->
    return `<div className="graph"></div>`
