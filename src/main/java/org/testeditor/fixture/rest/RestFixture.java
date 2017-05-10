package org.testeditor.fixture.rest;

import org.testeditor.fixture.core.interaction.FixtureMethod;

import com.mashape.unirest.http.HttpMethod;
import com.mashape.unirest.http.HttpResponse;
import com.mashape.unirest.http.exceptions.UnirestException;
import com.mashape.unirest.request.GetRequest;
import com.mashape.unirest.request.HttpRequest;
import com.mashape.unirest.request.HttpRequestWithBody;

public class RestFixture {

	private String baseUrl;

	@FixtureMethod
	public void setBaseUrl(String baseUrl) {
		this.baseUrl = baseUrl;
	}

	@FixtureMethod
	public HttpRequest createRequest(String locator, HttpMethod locatorStrategy) {
		switch (locatorStrategy) {
		case GET:
		case HEAD:
			return new GetRequest(locatorStrategy, baseUrl + locator);
		default:
			return new HttpRequestWithBody(locatorStrategy, baseUrl + locator);
		}
	}

	@FixtureMethod
	public HttpResponse<String> sendRequest(HttpRequest request) throws UnirestException {
		return request.asString();
	}

}
