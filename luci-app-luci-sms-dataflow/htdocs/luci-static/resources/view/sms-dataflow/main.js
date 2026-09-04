'use strict';
'require view';
'require request';

function endpoint(name) {
	return L.url('admin/services/sms-dataflow/' + name);
}

return view.extend({
	load: function() {
		return request.get(endpoint('modules')).then(function(res) {
			return res.json();
		});
	},

	render: function(data) {
		var modules = data.modules || [];
		var presets = data.presets || [];
		var moduleSelect = E('select', { 'class': 'cbi-input-select' });
		var presetSelect = E('select', { 'class': 'cbi-input-select' });
		var minutesInput = E('input', {
			'class': 'cbi-input-text',
			type: 'number',
			min: '1',
			max: '1440',
			value: '5'
		});

		if (modules.length) {
			modules.forEach(function(modem) {
				moduleSelect.appendChild(E('option', { value: modem.section }, '%s (%s)'.format(modem.section, modem.name)));
			});
		}
		else {
			moduleSelect.appendChild(E('option', { value: '' }, _('未发现 QModem 模块')));
		}

		presets.forEach(function(preset) {
			presetSelect.appendChild(E('option', { value: preset.id }, preset.name));
		});

		function submit(name, extra) {
			if (!moduleSelect.value)
				return;
			request.get(endpoint(name), Object.assign({
				module: moduleSelect.value,
				preset: presetSelect.value
			}, extra));
		}

		return E([], [
			E('h2', {}, _('短信检测')),
			E('div', { 'class': 'cbi-map' }, [
				E('div', { 'class': 'cbi-section' }, [
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('选择模块')),
						E('div', { 'class': 'cbi-value-field' }, moduleSelect)
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('选择运营商')),
						E('div', { 'class': 'cbi-value-field' }, presetSelect)
					]),
					E('div', { 'class': 'cbi-page-actions' }, [
						E('button', {
							'class': 'btn cbi-button cbi-button-positive',
							click: function() {
								submit('send');
							}
						}, _('立即检测'))
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('定时间隔（分钟）')),
						E('div', { 'class': 'cbi-value-field' }, minutesInput)
					]),
					E('div', { 'class': 'cbi-page-actions' }, [
						E('button', {
							'class': 'btn cbi-button cbi-button-action',
							click: function() {
								submit('interval', { minutes: minutesInput.value });
							}
						}, _('开启定时功能'))
					])
				])
			])
		]);
	}
});
