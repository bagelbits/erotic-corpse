import React from 'react';
import Modal from 'react-bootstrap/Modal';
import Button from 'react-bootstrap/Button';
import PropTypes from 'prop-types';

function ReportModal({ open, onClose, onReport, promptId }) {
  return (
    <Modal show={open} onHide={onClose}>
      <Modal.Header>
        <Modal.Title>Are you sure you want to report this?</Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p>Reporting a prompt will remove it from the story.</p>

        <p>Please only do this if the prompt is racist, sexist, or otherwise offensive.</p>

        <p>
          However, if a prompt has already been locked into the story, we will not be able to remove
          it.
        </p>
      </Modal.Body>

      <Modal.Footer>
        <Button
          variant="danger"
          onClick={() => {
            onReport(promptId);
          }}
        >
          Report
        </Button>
        <Button variant="outline-secondary" onClick={onClose}>
          Cancel
        </Button>
      </Modal.Footer>
    </Modal>
  );
}

ReportModal.propTypes = {
  open: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired,
  onReport: PropTypes.func.isRequired,
  promptId: PropTypes.number.isRequired,
};

export default ReportModal;
