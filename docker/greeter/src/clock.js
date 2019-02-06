import Ractive from "ractive"
import moment from "moment"

import "./clock.css"

const Clock = Ractive.extend({
	template: "<p class='clock' style='filter: blur({{ blur }}px);'>The day ends {{ time }}.</p>",
	data: function() {
		return {
			time: "sometime soon",
			blur: 0
		};
	},
	oncomplete: function() {
		setInterval(() => {
			this.set("time", moment().endOf("day").fromNow());
		}, 1024);

		setInterval(() => {
			this.set("blur", Math.random());
		}, 4096);
	},
})

export default Clock
