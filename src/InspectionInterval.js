import React, { Component } from 'react';
import Interval from './Interval';
import IntervalMonth from './IntervalMonth';

class InspectionInterval extends Component {

  render() {
    const intervals = this.props.intervals.original.InspectionIntervals;    

    const divStyle = {
        display: 'inline-block',
        position: 'relative',
        height: '40px'
    }

    const divBlockStyle = {
        display: 'inline-block',
        position: 'relative',
        height: '40px',
        width: '40px'
    }

    //      <Interval interval={interval} key={i} />    

    return (
        <div style={divStyle}>
          {intervals.map((interval, i) => {
            interval.Months.map((month, j) => <IntervalMonth interval={interval} month={month} key={j} />)          
          })}
        </div>        
    )
  }
}

export default InspectionInterval;