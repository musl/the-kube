import Ractive from 'ractive'

import "./greeting.css"

const Greeting = Ractive.extend({
	template: "<h1 class='greeting' style='color: {{ color }}; transform: rotate({{ angle }}deg);'>{{ message }}</h1>",
	data: function() {
		return {
			angle: 0,
			message: "Hello",
			colors: [
				"#ff0000",
				"#ffaa00",
				"#ffff00",
				"#aaff00",
				"#00ff00",
				"#00ffaa",
				"#00ffff",
				"#00aaff",
				"#0000ff",
				"#aa00ff",
				"#ff00ff",
				"#ff00aa"
			]
		};
	},
	oninit: function() {
		this.set("color", this.get("colors")[0]);
	},
	oncomplete: function() {
		var colors = this.get("colors");

		setInterval(() => {
			this.set("color", colors[Math.floor(Math.random() * colors.length)]);
		}, 1000);

		setInterval(() => {
			this.set("angle", -2 + 4 * Math.random());
		}, 5000);
	}
})

export default Greeting
