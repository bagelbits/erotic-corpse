import React from "react";

const DeliCounter = (props) => {
  const num_of_people = props.ticket - props.nowServing - 1;
  let line_string;
  if (num_of_people === 1) {
    line_string = `is ${num_of_people} person`;
  } else {
    line_string = `are ${num_of_people} people`;
  }
  return (
    <div>
      <p>There {line_string} ahead of you in line.</p>
    </div>
  );
};

export default DeliCounter;
