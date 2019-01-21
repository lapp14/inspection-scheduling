import React, { Component } from 'react';

class Facility extends Component {

  render() {  
    const fac = this.props.facility.original;
    const divStyle = {
        
    }

    return (
        <div style={divStyle}>
          <h3>
            {fac.FacilityName}
          </h3>
          <span>
            {fac.Category}
          </span><br/>
          <span>
            {fac.Inspector}
          </span>
        </div>        
    )
  }
}

export default Facility;