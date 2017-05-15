package org.testeditor.fixture.rest

import com.github.tomakehurst.wiremock.junit.WireMockRule
import org.junit.Before
import org.junit.Rule

import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.*

abstract class AbstractRestFixtureTest {

	@Rule
	public val wireMockRule = new WireMockRule(options.dynamicPort)

	protected val fixture = new RestFixture

	@Before
	def void setBaseUrl() {
		fixture.baseUrl = "http://localhost:" + wireMockRule.port
	}

}