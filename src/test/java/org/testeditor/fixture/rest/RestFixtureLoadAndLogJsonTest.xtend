/*******************************************************************************
 * Copyright (c) 2012 - 2018 Signal Iduna Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Signal Iduna Corporation - initial API and implementation
 * akquinet AG
 * itemis AG
 *******************************************************************************/

package org.testeditor.fixture.rest

import com.google.common.io.Files
import java.nio.charset.StandardCharsets
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.core.Appender
import org.apache.logging.log4j.core.LogEvent
import org.apache.logging.log4j.core.Logger
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.mockito.ArgumentCaptor

import static com.google.common.truth.Truth.assertThat

import static extension org.mockito.Mockito.*

class RestFixtureLoadAndLogJsonTest {

	@Rule
	public val folder = new TemporaryFolder

	val fixture = new RestFixture

	@Test
	def void parseJsonFromResource() {
		// when
		val json = fixture.parseJsonFromFile("sample.json")

		// then
		assertThat(json.asJsonObject.get("message").asString).isEqualTo("Hello, world!")
	}

	@Test
	def void parseJsonFromFile() {
		// given
		val source = '''
			{
				"message": "Hello, world!"
			}
		'''
		val file = folder.newFile("myFile.json")
		Files.write(source, file, StandardCharsets.UTF_8)

		// when
		val json = fixture.parseJsonFromFile(file.path)

		// then
		assertThat(json.asJsonObject.get("message").asString).isEqualTo("Hello, world!")
	}

	@Test
	def void logJson() {
		// given
		val mockAppender = addMockAppender
		val json = fixture.parseJsonFromFile("sample.json")

		// when
		fixture.logJson(json)

		// then
		val captor = ArgumentCaptor.forClass(LogEvent)
		verify(mockAppender).append(captor.capture)
		assertThat(captor.value.message.formattedMessage).isEqualTo('''
			Json is:
			{
			  "message": "Hello, world!"
			}
		'''.toString.trim.replaceAll('\r\n', '\n'))
	}

	private def Appender addMockAppender() {
		val mockAppender = Appender.mock => [
			when(name).thenReturn("MockAppender")
			when(isStarted).thenReturn(true)
			when(isStopped).thenReturn(false)
		]
		val logger = LogManager.getLogger(RestFixture) as Logger
		logger.addAppender(mockAppender)
		return mockAppender
	}

}
