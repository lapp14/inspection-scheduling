import React, { Component } from 'react';
import IntervalMonth from './IntervalMonth';

class Interval extends Component {

  render() {
    const intervalStyle = {
        border:  '1px solid black'
    }

    
    const clr = {
        clear: 'both'
    }


    return (
        <div style={intervalStyle}>
          {this.props.interval.Months.map((month, i) => <IntervalMonth month={month} key={i} />)}          
          <div style={clr}></div>
        </div>        
    )
  }
}

export default Interval;

