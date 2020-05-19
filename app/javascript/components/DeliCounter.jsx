import React from "react";

const DeliCounter = (props) => {
  return (
    <div>
      <p>Now Serving: {props.nowServing}</p>
      <p>Ticket: {props.ticket}</p>
      <p>Token: {props.token}</p>
    </div>
  );
};

export default DeliCounter;
