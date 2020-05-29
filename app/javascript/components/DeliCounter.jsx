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
    <div className="deli-counter">
      <p>There {line_string} ahead of you in line.</p>
      <p>
        Please do not refresh the page, or you will lose your place in line.
      </p>
      <p>
        <a href="http://nthmost.net:8000/kstk" target="_blank">
          Click here
        </a>{" "}
        to listen to Radio KTSK while you wait!
      </p>
    </div>
  );
};

export default DeliCounter;
