import React, { Component } from 'react';

class IntervalMonth extends Component {

  render() {
    const i = this.props.month;
    let bg = '#999999' //closed
    
    if(this.props.complete === true) {
      bg = '#80ff80'
    } else if(this.props.complete === false) {
      bg = '#ff471a'
    }     

    const divStyle = {
      fontSize:   '0.8em',
      textAlign:  'center',
      justifyContent: 'center',
      width:      '40px',
      height:     '40px',
      padding:    '2px',
      zIndex:     '100',
      display:    'flexbox',
      background: `${bg}`,
      order:      `${i}`
    }
    
    const getMonthName = (monthNumber) => {
      switch(monthNumber) {
        case 1:  return 'Jan'; 
        case 2:  return 'Feb'; 
        case 3:  return 'Mar'; 
        case 4:  return 'Apr'; 
        case 5:  return 'May'; 
        case 6:  return 'Jun'; 
        case 7:  return 'Jul'; 
        case 8:  return 'Aug'; 
        case 9:  return 'Sep'; 
        case 10: return 'Oct'; 
        case 11: return 'Nov'; 
        case 12: return 'Dec'; 
        default: return null;
      }
    }

    return (
        <div style={divStyle}>
          <span>{getMonthName(i)}</span>
        </div>        
    )
  }
}

export default IntervalMonth;

