import os
import subprocess
from flask import Flask, request, render_template_string, redirect, url_for, flash

app = Flask(__name__)
app.secret_key = os.environ.get("SITLWEB_SECRET", "change-me")

AUTH_TOKEN = os.environ.get("SITLWEB_TOKEN", "change-me")
RESET_SCRIPT = os.environ.get("SITLWEB_RESET", "/home/cyber/reset_one_sitl.sh")

NUM_TEAMS = int(os.environ.get("SITLWEB_TEAMS", "6"))
TCP_BASE   = int(os.environ.get("SITLWEB_TCP_BASE", "15000"))
TCP_STEP   = int(os.environ.get("SITLWEB_TCP_STEP", "10"))

PAGE = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><title>SITL Control</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: system-ui, sans-serif; max-width: 720px; margin: 2rem auto; padding: 0 1rem; }
    .row { display: flex; flex-wrap: wrap; gap: .5rem; margin: 1rem 0; }
    .card { border: 1px solid #ddd; border-radius: 8px; padding: 1rem; flex: 1 1 220px; }
    .msg { color: #064; margin:.5rem 0; }
    .err { color: #900; margin:.5rem 0; }
    input[type=password]{ width:100%; padding:.5rem; border:1px solid #ccc; border-radius:6px;}
    button{ padding:.6rem 1rem; border-radius:6px; border:1px solid #666; background:#f4f4f4; cursor:pointer;}
  </style>
</head>
<body>
  <h1>SITL Control Panel</h1>
  <p>Reset a simulator by its <strong>TCP port</strong>.</p>

  {% with messages = get_flashed_messages(with_categories=true) %}
    {% if messages %}{% for cat,msg in messages %}
      <div class="{{ 'err' if cat=='error' else 'msg' }}">{{ msg }}</div>
    {% endfor %}{% endif %}
  {% endwith %}

  <div class="row">
  {% for item in teams %}
    <div class="card">
      <h3>SITL @ TCP {{ item.tcp_port }}</h3>
      <div style="color:#777; font-size:.9rem;">(team {{ item.team }} / instance {{ item.instance }})</div>
      <form method="post" action="{{ url_for('reset_team', team=item.team) }}">
        <label>Token</label>
        <input type="password" name="token" placeholder="Access token" required>
        <div style="margin-top:.5rem"><button type="submit">Reset ({{ item.tcp_port }})</button></div>
      </form>
    </div>
  {% endfor %}
  </div>
</body>
</html>
"""

@app.get("/")
def index():
    teams = [{"team": i+1,
              "instance": i,
              "tcp_port": TCP_BASE + i * TCP_STEP} for i in range(NUM_TEAMS)]
    return render_template_string(PAGE, teams=teams)

@app.post("/reset/<int:team>")
def reset_team(team: int):
    token = request.form.get("token", "")
    if token != AUTH_TOKEN:
        flash("Invalid token.", "error")
        return redirect(url_for("index"))
    if not (1 <= team <= NUM_TEAMS):
        flash("Team out of range.", "error")
        return redirect(url_for("index"))
    try:
        res = subprocess.run(
            [RESET_SCRIPT, str(team)],
            check=True, capture_output=True, text=True, timeout=120
        )
        flash(res.stdout.strip() or f"Reset sent for team {team}.", "info")
    except subprocess.CalledProcessError as e:
        flash(f"Reset failed (exit {e.returncode}): {e.stderr}", "error")
    except Exception as e:
        flash(f"Exception: {e}", "error")
    return redirect(url_for("index"))
