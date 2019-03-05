import React, { Component } from 'react';
//import Interval from './Interval';
import IntervalMonth from './IntervalMonth';

class FacilityIntervals extends Component {

  render() {
    const intervals = this.props.intervals;    

    const divStyle = {
      //height: '40px',
      border: '1px solid black',
      display: 'inline-flex',
      flexDirection: 'row'
    }

    let months = [
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1,
      -1
    ]

    intervals.forEach((interval, index) => {
      interval['Months'].forEach((month) => {
        months[month - 1] = index
      })
    })

    function intervalComplete(month) {
      let index = months[month - 1];

      if(index === -1) {
        return 'closed';
      }

      return intervals[index].Complete;
    }
        
    return (
      <div style={divStyle}>
        <IntervalMonth month={1}  open={months[0]}  complete={intervalComplete(1)} />
        <IntervalMonth month={2}  open={months[1]}  complete={intervalComplete(2)} />
        <IntervalMonth month={3}  open={months[2]}  complete={intervalComplete(3)} />
        <IntervalMonth month={4}  open={months[3]}  complete={intervalComplete(4)} />
        <IntervalMonth month={5}  open={months[4]}  complete={intervalComplete(5)} />
        <IntervalMonth month={6}  open={months[5]}  complete={intervalComplete(6)} />
        <IntervalMonth month={7}  open={months[6]}  complete={intervalComplete(7)} />
        <IntervalMonth month={8}  open={months[7]}  complete={intervalComplete(8)} />
        <IntervalMonth month={9}  open={months[8]}  complete={intervalComplete(9)} />
        <IntervalMonth month={10} open={months[9]}  complete={intervalComplete(10)} />
        <IntervalMonth month={11} open={months[10]} complete={intervalComplete(11)} />
        <IntervalMonth month={12} open={months[11]} complete={intervalComplete(12)} />
      </div>        
    )
  }
}

export default FacilityIntervals;