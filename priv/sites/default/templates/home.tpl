{% extends "base.tpl" %}

{% block title %}{{ m.rsc[id].title }}{% endblock %}

{% block content %}

	{% if m.rsc[id].is_featured %}
	
		<h1>{{ m.rsc[id].title }}</h1>
		<p class="summary">{{ m.rsc[id].summary }}</p>
	
		{% for id in m.rsc[id].media %}
			<figure class="image-wrapper block-level-image">
				{% media id width=445 crop class=align alt=m.rsc[id].title %}
				{% if m.rsc[id].summary %}<p class="image-caption">{{ m.rsc[id].summary }}</p>{% endif %}
			</figure>
		{% endfor %}

	{% endif %}

	{% with m.search[{query cat='article' sort='-publication_start' pagelen=m.config.site.pagelen.value}] as result %}

		<div id="list-articles">
			{% for id in result %}
				{% include "_article_summary.tpl" id=id big=forloop.first %}
			{% endfor %}
		</div>

        {% ifequal m.config.site.pagelen.value result|length %}
			{% wire id="more-results" action={moreresults result=result target="list-articles" template="_article_summary.tpl"} %}
			<p><a href="javascript:void(0);" id="more-results">More results...</a></p>
        {% endifequal %}
	{% endwith %}

{% endblock %}
