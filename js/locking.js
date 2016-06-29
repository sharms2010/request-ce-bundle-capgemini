(function (window, $, moment) {
    // Ensure the locking namespace is prepared
    window.bundle.ext = window.bundle.ext || {};
    window.bundle.ext.locking = window.bundle.ext.locking || {
        config: {
            lockDuration: 60,
            lockInterval: 45
        }
    };
    
    // Create un-namespaced variables to simplify code
    var bundle = window.bundle;
    var locking = window.bundle.ext.locking;
    
    /**
     * Prepares a "heartbeat" AJAX call to the kappLocation+'?partial=lock' callback page.  This 
     * page attempts to update the 'Locked By' and 'Locked Until' submission values and returns a 
     * message describing the results of the call.
     * 
     * Config options:
     * - element
     * - lockDuration
     * - lockInterval
     * - onBefore
     * - onFailure
     * - onSuccess
     * 
     * @param {type} kineticForm
     * @param {type} config
     * @returns {undefined}
     */
    locking.observe = function(kineticForm, config) {
        // Determine the configuration options
        config = config || {};
        var lockDuration = config.lockDuration || locking.config.lockDuration;
        var lockInterval = config.lockInterval || locking.config.lockInterval;
        if (lockDuration <= lockInterval) {
            throw "Calls to bundle.ext.locking.observe must pass a config.lockDuration that is "+
                "greater than the config.lockInterval."
        }
        // Calculate the url parameters
        var id = kineticForm.submission().id();
        var until = moment().add(lockDuration, 'seconds').toISOString();
        // If the config defines an onBefore callback function, call it
        if (typeof config.onBefore === 'function') {
            config.onBefore.apply(kineticForm);
        }
        // Make the AJAX call
        $.ajax({
            method: 'GET',
            url: bundle.kappLocation()+'?partial=lock&id='+id+'&until='+until,
            contentType: 'application/json',
            headers: {
                // Use X-HTTP-Method-Override because presently the Kinetic routes for spaces,
                // kapps, and forms only accept GET requests.
                'X-HTTP-Method-Override': 'PUT'
            },
            success: function(content) {
                // If an explicit onSuccess handler is specified, call it
                if (typeof config.onSuccess === 'function') {
                    config.onSuccess.apply(kineticForm, content);
                }
                // If there is not an explicit onSuccess handler, call a default (which sets the 
                // html content of the configuration element or prepends a div to the kinetic form
                // if a config element is not specified.
                else {
                    // Initialize 
                    config.element = config.element || $('<div>').prependTo(kineticForm.element());
                    // Write the content
                    $(config.element).html(content);
                }
                // Recall lock after the timeout interval
                setTimeout(function() {
                    locking.observe(kineticForm, config);
                }, lockInterval*1000);
            },
            failure: function(request) {
                // If the config defines an onFailure callback function, call it
                if (typeof config.onFailure === 'function') {
                    config.onFailure.apply(kineticForm, request);
                }
            }
        });
    };
})(window, $, moment);
