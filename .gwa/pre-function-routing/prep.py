import json
script = """

if kong.request.get_query_arg("layers") ~= "pub:WHSE_HUMAN_CULTURAL_ECONOMIC.EMRG_ORDER_AND_ALERT_AREAS_SP" then
    kong.service.request.set_header("x-event", "to-beid")
    kong.service.set_target("142.34.140.41", 443)
    kong.service.request.set_scheme("https")
else
    kong.service.request.set_header("x-event", "to-ocp")
end
"""

print(json.dumps(script.strip()))
