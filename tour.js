import {Nyarna, Input, Result} from "/nyarna.js";

let interpreter = Nyarna.instantiate("/nyarna.wasm");

function showPopup(success, items) {
  document.getElementById("popup-title").dataset["kind"] = success ? "success" : "failure";
  const content = document.getElementById("popup-content");
  while (content.firstChild) content.removeChild(content.firstChild);
  const container = document.createElement("div");
  container.classList.add("output-panels");
  for (const [index, item] of items.entries()) {
    const input = document.createElement("input");
    input.type = "radio";
    input.name = "output-tabs";
    input.id = `output-${index}`;
    if (index == 0) input.checked = true;
    content.appendChild(input);

    const label = document.createElement("label");
    label.for = input.id;
    label.innerText = item.name || "<stdout>";
    content.appendChild(label);

    const textarea = document.createElement("textarea");
    textarea.readOnly = true;
    textarea.value = item.content;
    container.appendChild(textarea);
  }
  content.appendChild(container);

  document.getElementById("popup-shown").checked = true;
}

window.execNyarna = function(e) {
  e.preventDefault();
  interpreter.then((n) => {
    const input = new Input(n);
    const form = e.target;
    const modules = form.querySelectorAll("textarea");
    for (const module of modules) {
      input.pushInput(module.name, module.value);
    }
    for (const ip of form.querySelectorAll(".interpret .arg > input")) {
      input.pushArg(ip.name, ip.value);
    }
    const result = input.process(modules[0].name);
    if (result.errors) {
      showPopup(false, [{name: "errors", content: result.errors}]);
    } else {
      showPopup(true, result.documents);
    }
  });
}