    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/social-share.js@1.0.16/dist/css/share.min.css">
<script src="https://cdn.jsdelivr.net/npm/social-share.js@1.0.16/dist/js/social-share.min.js"></script>
<div class="social-share share-component" style='text-align:center'>
</div>
<div class="reward-container">
  <div>{{ page.reward_settings.comment }}</div>
  <button onclick="var qr = document.getElementById('qr'); qr.style.display = (qr.style.display === 'none') ? 'block' : 'none';">
    {{ __('reward.donate') }}
  </button>
  <div id="qr" style="display: none;">

    {%- for name, image in theme.reward %}
      {%- set builtin = ['wechatpay', 'alipay', 'paypal', 'bitcoin'] %}
      {%- if builtin.includes(name) %}
        {%- set translation = __('reward.' + name) %}
      {% else %}
        {%- set translation = name %}
      {%- endif %}
      <div style="display: inline-block;">
        <img src="{{ url_for(image) }}" alt="{{ author }} {{ translation }}">
        <p>{{ translation }}</p>
      </div>
    {%- endfor %}

  </div>
</div>
