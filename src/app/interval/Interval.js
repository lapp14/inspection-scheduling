import React, { Component } from 'react';
import IntervalMonth from './IntervalMonth';

class Interval extends Component {

  render() {
    return (
      this.props.interval.Months.map((month, i) => 
        <IntervalMonth month={month} complete={this.props.interval.Complete} key={i} />
      )        
    )
  }
}

export default Interval;

