import React, { Component } from 'react';
import axios from 'axios';
import './App.css';

import ReactTable from "react-table";
import FacilityIntervals from './app/interval/FacilityIntervals';
import Facility from './app/facility/Facility';
import "react-table/react-table.css";

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      data: {
        'Facilities': []
      }
    }
  }

  getData(year, category) {
    axios.get(`http://localhost:5000/completion/?year=${year}&category=${category}`)
      .then( (response) => {
        this.setState({data: response.data});
      })
  }

  componentDidMount() {
    this.getData(2019, 'General Food')
  }
 /* <ReactTable
  data={this.state.data.Facilities}
  columns={[
    {
      Header: 'Facility Name',
      accessor: 'FacilityName'
    },
    {
      Header: 'Category',
      accessor: 'Category'
    },
    {
      Header: 'Inspector',
      accessor: 'Inspector'
    },
    {
      Header: 'Risk',
      accessor: 'Risk'
    },
    {
      Header: 'Inspections',
      accessor: 'InspectionIntervals',
      Cell: row => <InspectionInterval intervals={row}/>
    }
  ]}
/>*/


//{this.state.data.Facilities.map((fac, i) => <Facility facility={fac} key={i} />)}

  render() {
    return (
      <div className="App">
        <header className="App-header">
          Scheduling
        </header>
        <div className="app-content">
          
          <ReactTable
            data={this.state.data.Facilities}
            columns={[
              {
                Header: 'Facility',
                accessor: 'FacilityName',
                Cell: row => <Facility facility={row}/>
              },
              {
                Header: 'Inspections',
                accessor: 'InspectionIntervals',
                Cell: row => <FacilityIntervals intervals={row.original.InspectionIntervals}/>
              }
            ]}
          />      
        </div>
      </div>
    );
  }
}

export default App;
