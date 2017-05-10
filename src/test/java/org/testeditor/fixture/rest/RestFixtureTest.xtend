package org.testeditor.fixture.rest

import com.github.tomakehurst.wiremock.junit.WireMockRule
import com.mashape.unirest.http.HttpMethod
import com.mashape.unirest.request.GetRequest
import com.mashape.unirest.request.HttpRequestWithBody
import org.junit.Before
import org.junit.Rule
import org.junit.Test

import static com.github.tomakehurst.wiremock.client.WireMock.*
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.*
import static com.google.common.truth.Truth.assertThat

class RestFixtureTest {

	@Rule
	public val wireMockRule = new WireMockRule(options.dynamicPort)

	val fixture = new RestFixture

	@Before
	def void setBaseUrl() {
		fixture.baseUrl = "http://localhost:" + wireMockRule.port
	}

	@Test
	def void createRequestHttpGet() {
		// when
		val request = fixture.createRequest("/someService", HttpMethod.GET)

		// then
		assertThat(request).isInstanceOf(GetRequest)
		assertThat(request.url).isEqualTo('''http://localhost:«wireMockRule.port»/someService'''.toString)
		assertThat(request.httpMethod).isEqualTo(HttpMethod.GET)
	}

	@Test
	def void createRequestHttpPost() {
		// when
		val request = fixture.createRequest("/someService", HttpMethod.POST)

		// then
		assertThat(request).isInstanceOf(HttpRequestWithBody)
		assertThat(request.httpMethod).isEqualTo(HttpMethod.POST)
	}

	@Test
	def void sendSimpleRequest() {
		// given
		val request = fixture.createRequest("/someService", HttpMethod.GET)
		stubFor(any(urlPathEqualTo("/someService")))

		// when
		val response = fixture.sendRequest(request)

		// then
		verify(getRequestedFor(urlPathEqualTo("/someService")))
		assertThat(response.status).isEqualTo(200)
	}

}
