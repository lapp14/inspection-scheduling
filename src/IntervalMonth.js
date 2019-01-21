import React, { Component } from 'react';

class IntervalMonth extends Component {

  render() {
    const i = this.props.month;
    const bg = this.props.interval.Complete === true ? '#80ff80' : '#ff471a'
    const margin = (i - 1) * 40 + 'px'

    const divStyle = {
        width:   '40px',
        height:  '40px',
        zIndex:  '100',
        position: 'absolute',
        display: 'inline-block',
        background: `${bg}`,
        left: `${margin}`,
        top: 0
    }

    return (
        <div style={divStyle}>
          {i}
        </div>        
    )
  }
}

export default IntervalMonth;

