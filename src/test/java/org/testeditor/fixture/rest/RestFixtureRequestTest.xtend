package org.testeditor.fixture.rest

import com.github.tomakehurst.wiremock.client.BasicCredentials
import com.google.gson.JsonParser
import com.mashape.unirest.http.HttpMethod
import com.mashape.unirest.request.GetRequest
import com.mashape.unirest.request.HttpRequest
import com.mashape.unirest.request.HttpRequestWithBody
import org.junit.Before
import org.junit.Test

import static com.github.tomakehurst.wiremock.client.WireMock.*
import static com.google.common.truth.Truth.assertThat

class RestFixtureRequestTest extends AbstractRestFixtureTest {

	HttpRequest request

	@Before
	def void createRequest() {
		request = fixture.createRequest("/someService", HttpMethod.POST)
		stubFor(any(urlPathEqualTo("/someService")))
	}

	@Test
	def void createRequestHttpPost() {
		// when: done by before method
		// then
		assertThat(request).isInstanceOf(HttpRequestWithBody)
		assertThat(request.httpMethod).isEqualTo(HttpMethod.POST)
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

	@Test
	def void addHeader() {
		// when
		fixture.addHeader(request, "myHeader", "myValue")
		fixture.sendRequest(request)

		// then
		verify(
			postRequestedFor(urlEqualTo("/someService")).withHeader("myHeader", equalTo("myValue"))
		)
	}

	@Test
	def void addBasicAuth() {
		// when
		fixture.addBasicAuth(request, "peter", "topSecret")
		fixture.sendRequest(request)

		// then
		verify(
			postRequestedFor(urlEqualTo("/someService")).withBasicAuth(new BasicCredentials("peter", "topSecret"))
		)
	}

	@Test
	def void addQueryString() {
		// when
		fixture.addQueryString(request, "param1", "value1")
		fixture.addQueryString(request, "寺", "value with stuff to escape @")
		fixture.sendRequest(request)

		// then
		verify(postRequestedFor(
			// 寺 should be encoded as %E5%AF%BA
			urlEqualTo("/someService?param1=value1&%E5%AF%BA=value+with+stuff+to+escape+%40")
		))
	}

	@Test
	def void setBody() {
		// given
		val json = new JsonParser().parse('''
			{
				"message": "Hello, world!"
			}
		''')

		// when
		fixture.setBody(request, json)
		fixture.sendRequest(request)

		// then
		verify(postRequestedFor(anyUrl).withRequestBody(equalToJson('''{"message":"Hello, world!"}''')))
	}

	@Test(expected=IllegalArgumentException)
	def void setBodyFailsOnGetRequest() {
		// given
		val getRequest = fixture.createRequest("/someService", HttpMethod.GET)
		val json = new JsonParser().parse('{}')

		// when
		fixture.setBody(getRequest, json)
	}

	@Test
	def void getStatus() {
		// given
		stubFor(any(urlPathEqualTo("/someService")).willReturn(aResponse.withStatus(321)))
		val response = fixture.sendRequest(request)

		// when
		val status = fixture.getStatus(response)

		// then
		assertThat(status).isEqualTo(321)
	}

	@Test
	def void parseResponseBody() {
		// given
		stubFor(any(urlPathEqualTo("/someService")).willReturn(aResponse.withBody('''{"message":"Hello, world!"}''')))
		val response = fixture.sendRequest(request)

		// when
		val body = fixture.parseResponseBody(response)

		// then
		assertThat(body.asJsonObject.get("message").asString).isEqualTo("Hello, world!")
	}

}
