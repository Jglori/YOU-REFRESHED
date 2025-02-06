import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Modal extends LightningModal {
    @api label;
    @api content;
    @api image;
    @api confirmCallback;
    @api isOneButton;

    handleConfirm() {
        if (this.confirmCallback) {
            this.confirmCallback();
        }
        this.close('confirm');
    }

    handleClose() {
        this.close('cancel');
    }
};