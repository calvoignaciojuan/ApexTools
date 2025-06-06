import { createElement } from '@lwc/engine-dom';
import Lwc10_CustomEvents_Parent from 'c/lwc10_CustomEvents_Parent';

describe('c-lwc10-custom-events-parent', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-lwc10-custom-events-parent', {
            is: Lwc10_CustomEvents_Parent
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});